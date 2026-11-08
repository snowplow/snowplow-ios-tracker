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

class SignalsControllerImpl: Controller, SignalsController, SignalsThrowingHandlerRegistering {
    static let interventionsPluginIdentifier = "signalsInterventionsPluginInternal"

    /// Created when the first intervention handler is added.
    private(set) var interventions: InterventionsSubscription?

    // MARK: - Service attributes

    func getServiceAttributes(
        service: String,
        attributeKey: String?,
        identifier: String?,
        completion: @escaping ([String: Any]?, SignalsError?) -> Void
    ) {
        let finish = { (attributes: [String: Any]?, error: SignalsError?) in
            if let error = error {
                logError(message: "Signals read of service \(service) failed (\(error.status)): \(error.message)")
            }
            DispatchQueue.main.async { completion(attributes, error) }
        }

        guard let configuration = serviceProvider.signalsConfiguration else {
            finish(nil, SignalsControllerImpl.notConfiguredError)
            return
        }
        let attributeKey = attributeKey ?? kSPSignalsUserIdAttributeKey
        let resolvedIdentifier: String
        switch resolveIdentifier(attributeKey: attributeKey, identifier: identifier) {
        case .failure(let error):
            finish(nil, error)
            return
        case .success(let value):
            resolvedIdentifier = value
        }
        guard let url = SignalsNetworking.serviceUrl(baseUrl: configuration.baseUrl,
                                                     service: service,
                                                     attributeKey: attributeKey,
                                                     identifier: resolvedIdentifier) else {
            finish(nil, SignalsError(status: 0, message: "Invalid Signals endpoint: \(configuration.endpoint)"))
            return
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: configuration.timeout)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let session = SignalsNetworking.makeSession(timeout: configuration.timeout)
        let task = session.dataTask(with: request) { data, response, error in
            session.finishTasksAndInvalidate()
            let result = SignalsControllerImpl.parseServiceResponse(data: data, response: response, error: error)
            switch result {
            case .success(let attributes): finish(attributes, nil)
            case .failure(let error): finish(nil, error)
            }
        }
        task.resume()
    }

    static func parseServiceResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<[String: Any], SignalsError> {
        if let error = error {
            return .failure(SignalsError(status: 0, message: error.localizedDescription))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(SignalsError(status: 0, message: "No response from Signals"))
        }
        let statusCode = httpResponse.statusCode
        guard (200..<300).contains(statusCode) else {
            return .failure(SignalsError(status: statusCode,
                                         message: SignalsNetworking.errorMessage(data: data, statusCode: statusCode)))
        }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let attributes = json["attributes"] as? [String: Any] else {
            return .failure(SignalsError(status: statusCode, message: "Unexpected Signals response, missing attributes"))
        }
        return .success(attributes)
    }

    // MARK: - Interventions

    func addInterventionHandler(id: String, handler: @escaping (SignalsIntervention) -> Void) {
        addThrowingInterventionHandler(id: id, handler: handler)
    }

    func addThrowingInterventionHandler(id: String, handler: @escaping (SignalsIntervention) throws -> Void) {
#if os(watchOS)
        logError(message: "Signals interventions are not supported on watchOS")
#else
        guard let configuration = serviceProvider.signalsConfiguration else {
            logError(message: "Can't add Signals intervention handler \(id): \(SignalsControllerImpl.notConfiguredError.message)")
            return
        }
        let tracker = serviceProvider.tracker
        if tracker.userAnonymisation {
            logError(message: "Signals interventions are not delivered while user anonymisation is enabled")
        } else if tracker.session == nil {
            logError(message: "Signals interventions are not delivered: \(SignalsControllerImpl.sessionDisabledError.message)")
        }

        let interventions = makeInterventionsIfNeeded()
        interventions.configure(baseUrl: configuration.baseUrl)
        interventions.updateIdentifiers(userId: tracker.session?.userId,
                                        sessionId: tracker.session?.sessionId,
                                        isAnonymised: tracker.userAnonymisation)
        interventions.addHandler(id: id, handler: handler)
#endif
    }

    func removeInterventionHandler(id: String) {
        interventions?.removeHandler(id: id)
    }

    /// Closes the interventions stream, e.g. before the tracker is reset or shut down.
    func stopInterventions() {
        interventions?.stop()
    }

    /// Reconnects the interventions stream with the current configuration, after the tracker was reset.
    func resumeInterventions() {
        interventions?.configure(baseUrl: serviceProvider.signalsConfiguration?.baseUrl)
    }

    private func makeInterventionsIfNeeded() -> InterventionsSubscription {
        if let interventions = interventions { return interventions }

        let serviceProvider = self.serviceProvider
        let interventions = InterventionsSubscription { [weak serviceProvider] event in
            InternalQueue.async {
                _ = serviceProvider?.trackerController.track(event)
            }
        }
        self.interventions = interventions

        // keeps the identifiers current from the session entity of tracked events
        let plugin = PluginConfiguration(identifier: SignalsControllerImpl.interventionsPluginIdentifier)
        _ = plugin.afterTrack { [weak interventions] event in
            guard let session = event.entities.first(where: { $0.schema == kSPSessionContextSchema }) else { return }
            let userId = session.data[kSPSessionUserId] as? String
            interventions?.updateIdentifiers(userId: userId,
                                             sessionId: session.data[kSPSessionId] as? String,
                                             isAnonymised: userId == kSPSessionAnonymousUserId)
        }
        serviceProvider.addPlugin(plugin: plugin)
        return interventions
    }

    // MARK: - Identifiers

    /// Resolves the identifier to read or subscribe with, refusing when the tracker's identifiers are unusable.
    /// Must be called on the InternalQueue.
    func resolveIdentifier(attributeKey: String, identifier: String?) -> Result<String, SignalsError> {
        let tracker = serviceProvider.tracker
        if tracker.userAnonymisation {
            return .failure(SignalsError(status: 0, message: "Signals is not available when user anonymisation is enabled"))
        }
        if let identifier = identifier {
            return .success(identifier)
        }
        switch attributeKey {
        case kSPSignalsUserIdAttributeKey:
            guard let session = tracker.session else {
                return .failure(SignalsControllerImpl.sessionDisabledError)
            }
            return .success(session.userId)
        case kSPSignalsSessionIdAttributeKey:
            guard let session = tracker.session else {
                return .failure(SignalsControllerImpl.sessionDisabledError)
            }
            guard let sessionId = session.sessionId else {
                return .failure(SignalsError(status: 0, message: "No session ID yet; it is created on the first tracked event"))
            }
            return .success(sessionId)
        default:
            return .failure(SignalsError(status: 0, message: "An identifier is required for attribute key \(attributeKey)"))
        }
    }

    // MARK: - Errors

    static let notConfiguredError = SignalsError(
        status: 0,
        message: "Signals is not configured; pass a SignalsConfiguration when creating the tracker")

    static let sessionDisabledError = SignalsError(
        status: 0,
        message: "No session identifiers; session tracking (TrackerConfiguration.sessionContext) is disabled")
}
