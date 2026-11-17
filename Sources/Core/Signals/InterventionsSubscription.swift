//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.

import Foundation
#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

let kSPSignalsInterventionReceiveSchema = "iglu:com.snowplowanalytics.signals/intervention_receive/jsonschema/1-0-0"
let kSPSignalsInterventionHandleSchema = "iglu:com.snowplowanalytics.signals/intervention_handle/jsonschema/1-0-0"
let kSPSignalsInterventionHandleErrorSchema = "iglu:com.snowplowanalytics.signals/intervention_handle_error/jsonschema/1-0-0"
let kSPSignalsInterventionInstanceSchema = "iglu:com.snowplowanalytics.signals/intervention_instance/jsonschema/1-0-0"

/// Keeps a server-sent events subscription to `GET {endpoint}/api/v1/interventions` open while there are handlers,
/// dispatches the received interventions to them and tracks the intervention measurement events.
///
/// The stream is keyed on the session context identifiers (`client_session_user_id`, `client_session_session_id`),
/// which are kept current from tracked events; the stream reconnects when they change.
/// It is closed while the app is in the background, when user anonymisation is on and when there are no handlers.
/// Failed connections are retried with exponential backoff, except for 4xx responses, which are only retried once
/// the identifiers change.
///
/// All state is accessed on `queue`, which is also the URL session delegate queue.
class InterventionsSubscription: NSObject, URLSessionDataDelegate {
    typealias Handler = (SignalsIntervention) throws -> Void

    /// Idle timeout of the stream; the server sends a heartbeat comment every 5 seconds.
    static let streamIdleTimeout: TimeInterval = 30
    /// Upper bound of the delay between reconnection attempts, in seconds.
    static var maxRetryDelay: TimeInterval = 60
    /// Delay before the first reconnection attempt, in seconds; doubles with every failed attempt.
    static var initialRetryDelay: TimeInterval = 1

    let queue = DispatchQueue(label: "snowplow.signals.interventions")
    private lazy var delegateQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.underlyingQueue = queue
        return operationQueue
    }()

    /// Tracks a measurement event with the tracker.
    private let track: (Event) -> Void

    private var baseUrl: String?
    private var handlers: [(id: String, handler: Handler)] = []
    private var userId: String?
    private var sessionId: String?
    private var isAnonymised = false
    private var isInBackground = false

    private var urlSession: URLSession?
    private var task: URLSessionDataTask?
    /// URL of the open (or opening) connection.
    private var connectedUrl: URL?
    /// URL that the server rejected with a 4xx status; not retried until the identifiers change.
    private var rejectedUrl: URL?
    private var failedStatusCode: Int?
    private var failedResponseBody = Data()
    private let parser = EventStreamParser()

    private var retryAttempt = 0
    private var retryWorkItem: DispatchWorkItem?
    /// URL that the scheduled retry is for.
    private var retryUrl: URL?

    init(track: @escaping (Event) -> Void) {
        self.track = track
        super.init()
#if os(iOS) || os(tvOS) || os(visionOS)
        isInBackground = !AppStateProvider.isVisible
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
#endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Updates

    /// Sets the Signals endpoint, or nil when Signals isn't configured.
    func configure(baseUrl: String?) {
        queue.async {
            self.baseUrl = baseUrl
            self.reconcile()
        }
    }

    func addHandler(id: String, handler: @escaping Handler) {
        queue.async {
            if let index = self.handlers.firstIndex(where: { $0.id == id }) {
                self.handlers[index] = (id, handler)
            } else {
                self.handlers.append((id, handler))
            }
            self.reconcile()
        }
    }

    func removeHandler(id: String) {
        queue.async {
            self.handlers.removeAll { $0.id == id }
            self.reconcile()
        }
    }

    /// Updates the identifiers to subscribe with.
    /// - Parameter isAnonymised: Whether user anonymisation is on, in which case no subscription is made.
    func updateIdentifiers(userId: String?, sessionId: String?, isAnonymised: Bool) {
        queue.async {
            self.userId = userId
            self.sessionId = sessionId
            self.isAnonymised = isAnonymised
            self.reconcile()
        }
    }

    /// Closes the stream and stops reconnecting; the handlers and identifiers are kept.
    func stop() {
        queue.async {
            self.baseUrl = nil
            self.reconcile()
        }
    }

    // MARK: - Lifecycle

    @objc private func didEnterBackground() {
        queue.async {
            self.isInBackground = true
            self.reconcile()
        }
    }

    @objc private func willEnterForeground() {
        queue.async {
            self.isInBackground = false
            self.cancelRetry()
            self.retryAttempt = 0
            self.reconcile()
        }
    }

    // MARK: - Connection

    /// The URL to subscribe to in the current state, or nil when there should be no subscription.
    private var desiredUrl: URL? {
        guard let baseUrl = baseUrl,
              !handlers.isEmpty,
              !isAnonymised,
              !isInBackground,
              let userId = userId,
              let sessionId = sessionId else {
            return nil
        }
        return SignalsNetworking.url(baseUrl: baseUrl,
                                     path: "/api/v1/interventions",
                                     query: [(kSPSignalsUserIdAttributeKey, userId),
                                             (kSPSignalsSessionIdAttributeKey, sessionId)])
    }

    /// Opens, keeps or closes the stream to match the current state.
    private func reconcile() {
        guard let url = desiredUrl else {
            if connectedUrl != nil || retryWorkItem != nil {
                logDebug(message: "Closing the Signals interventions stream")
            }
            disconnect()
            cancelRetry()
            return
        }
        if url == connectedUrl || url == rejectedUrl {
            return
        }
        if retryWorkItem != nil {
            if url == retryUrl { return } // wait for the scheduled retry
            cancelRetry()
            retryAttempt = 0
        }
        connect(url: url)
    }

    private func connect(url: URL) {
        disconnect()
        rejectedUrl = nil
        logDebug(message: "Subscribing to Signals interventions")

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: InterventionsSubscription.streamIdleTimeout)
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        let session = SignalsNetworking.makeSession(timeout: InterventionsSubscription.streamIdleTimeout,
                                                    delegate: self,
                                                    delegateQueue: delegateQueue)
        let task = session.dataTask(with: request)
        urlSession = session
        self.task = task
        connectedUrl = url
        failedStatusCode = nil
        failedResponseBody = Data()
        parser.reset()
        task.resume()
    }

    private func disconnect() {
        task = nil
        connectedUrl = nil
        // releases the session's strong reference to its delegate (self)
        urlSession?.invalidateAndCancel()
        urlSession = nil
    }

    private func scheduleRetry(url: URL) {
        let delay = min(InterventionsSubscription.initialRetryDelay * pow(2, Double(retryAttempt)),
                        InterventionsSubscription.maxRetryDelay)
        retryAttempt += 1
        logDebug(message: "Reconnecting to Signals interventions in \(delay) s")
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.retryWorkItem = nil
            self.retryUrl = nil
            self.reconcile()
        }
        retryWorkItem = workItem
        retryUrl = url
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func cancelRetry() {
        retryWorkItem?.cancel()
        retryWorkItem = nil
        retryUrl = nil
    }

    // MARK: - URLSessionDataDelegate

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard dataTask === task else {
            completionHandler(.cancel)
            return
        }
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if statusCode == 200 {
            retryAttempt = 0
            logDebug(message: "Subscribed to Signals interventions")
        } else {
            // read the error body, handled on completion
            failedStatusCode = statusCode
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard dataTask === task else { return }
        if failedStatusCode != nil {
            failedResponseBody.append(data)
            return
        }
        for message in parser.append(data) {
            handle(message: message)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard task === self.task, let url = connectedUrl else { return }
        disconnect()

        if let statusCode = failedStatusCode {
            let message = SignalsNetworking.errorMessage(data: failedResponseBody, statusCode: statusCode)
            logError(message: "Signals interventions subscription failed (\(statusCode)): \(message)")
            if (400..<500).contains(statusCode) {
                rejectedUrl = url
                return
            }
        } else if let error = error {
            logError(message: "Signals interventions stream failed: \(error.localizedDescription)")
        } else {
            logDebug(message: "Signals interventions stream closed by the server")
        }
        scheduleRetry(url: url)
    }

    // MARK: - Dispatch

    private func handle(message: EventStreamMessage) {
        switch message.event {
        case "message":
            guard let data = message.data.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let intervention = SignalsIntervention(json: json) else {
                logError(message: "Received an invalid Signals intervention: \(message.data)")
                return
            }
            dispatch(intervention)
        case "error":
            logError(message: "Signals interventions stream error: \(message.data)")
        default:
            break
        }
    }

    /// Tracks the delivery and calls each handler on the main queue, tracking whether it handled the intervention.
    private func dispatch(_ intervention: SignalsIntervention) {
        let handlers = self.handlers
        guard !handlers.isEmpty else { return }
        logDebug(message: "Dispatching Signals intervention \(intervention.name) to \(handlers.count) handler(s)")

        track(measurementEvent(schema: kSPSignalsInterventionReceiveSchema,
                               data: ["handlers": handlers.map { $0.id }],
                               intervention: intervention))

        for (id, handler) in handlers {
            DispatchQueue.main.async {
                do {
                    try handler(intervention)
                    self.track(self.measurementEvent(schema: kSPSignalsInterventionHandleSchema,
                                                     data: ["handler": id],
                                                     intervention: intervention))
                } catch {
                    logError(message: "Signals intervention handler \(id) failed: \(error)")
                    self.track(self.measurementEvent(schema: kSPSignalsInterventionHandleErrorSchema,
                                                     data: ["handler": id, "error": String(describing: error)],
                                                     intervention: intervention))
                }
            }
        }
    }

    private func measurementEvent(schema: String, data: [String: Any], intervention: SignalsIntervention) -> Event {
        let event = SelfDescribing(schema: schema, payload: data)
        event.entities.append(SelfDescribingJson(schema: kSPSignalsInterventionInstanceSchema,
                                                 andDictionary: intervention.entityData))
        return event
    }
}
