//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

/// This class sends events to the collector.
let POST_WRAPPER_BYTES = 88

class Emitter: EmitterEventProcessing {
    
    private var timer: InternalQueueTimer?
    
    private var pausedEmit = false
    
    /// Custom NetworkConnection istance to handle connection outside the emitter.
    private let networkConnection: NetworkConnection
    
    /// Tracker namespace – required by SQLiteEventStore to name the database
    let namespace: String
    
    let eventStore: EventStore
    
    /// Whether the emitter is currently sending.
    var isSending: Bool = false

    /// Collector endpoint.
    var urlEndpoint: String? {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.urlEndpoint?.absoluteString
            }
            return nil
        }
        set {
            if let urlString = newValue,
               let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.urlString = urlString
            }
        }
    }
    
    /// Security of requests - ProtocolHttp or ProtocolHttps.
    var `protocol`: ProtocolOptions {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.protocol
            }
            return EmitterDefaults.httpProtocol
        }
        set {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.protocol = newValue
            }
        }
    }
    
    /// Chosen HTTP method - .get or .post.
    var method: HttpMethodOptions {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.httpMethod
            }
            return EmitterDefaults.httpMethod
        }
        set(method) {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.httpMethod = method
            }
        }
    }
        
    /// Buffer option
    var bufferOption: BufferOption = EmitterDefaults.bufferOption
    
    /// Callbacks supplied with number of failures and successes of sent events.
    weak var callback: RequestCallback?
    
    private var _emitRange = EmitterDefaults.emitRange
    /// Number of events retrieved from the database when needed.
    var emitRange: Int {
        get { return _emitRange }
        set(emitRange) {
            if emitRange > 0 {
                _emitRange = emitRange
            }
        }
    }
    
    /// Number of threads used for emitting events.
    var emitThreadPoolSize: Int {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.emitThreadPoolSize
            }
            return EmitterDefaults.emitThreadPoolSize
        }
        set(emitThreadPoolSize) {
            if emitThreadPoolSize > 0 {
                if let networkConnection = networkConnection as? DefaultNetworkConnection {
                    networkConnection.emitThreadPoolSize = emitThreadPoolSize
                }
            }
        }
    }
    
    /// Byte limit for GET requests.
    private var _byteLimitGet = EmitterDefaults.byteLimitGet
    var byteLimitGet: Int {
        get { return _byteLimitGet }
        set(byteLimitGet) {
            _byteLimitGet = byteLimitGet
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.byteLimitGet = byteLimitGet
            }
        }
    }
    
    private var _byteLimitPost = EmitterDefaults.byteLimitPost
    /// Byte limit for POST requests.
    var byteLimitPost: Int {
        get { return _byteLimitPost }
        set(byteLimitPost) {
            _byteLimitPost = byteLimitPost
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.byteLimitPost = byteLimitPost
            }
        }
    }

    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`.
    var serverAnonymisation: Bool {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.serverAnonymisation
            }
            return EmitterDefaults.serverAnonymisation
        }
        set(serverAnonymisation) {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.serverAnonymisation = serverAnonymisation
            }
        }
    }

    /// Custom endpoint path for POST requests.
    var customPostPath: String? {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.customPostPath
            }
            return nil
        }
        set(customPath) {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.customPostPath = customPath
            }
        }
    }

    /// Custom header requests.
    var requestHeaders: [String : String]? {
        get {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                return networkConnection.requestHeaders
            }
            return nil
        }
        set(requestHeaders) {
            if let networkConnection = networkConnection as? DefaultNetworkConnection {
                networkConnection.requestHeaders = requestHeaders
            }
        }
    }
    
    /// Custom retry rules for HTTP status codes.
    private var _customRetryForStatusCodes: [Int : Bool] = [:]
    var customRetryForStatusCodes: [Int : Bool]? {
        get { return _customRetryForStatusCodes }
        set { _customRetryForStatusCodes = newValue ?? [:] }
    }
    
    /// Whether retrying failed requests is allowed
    var retryFailedRequests: Bool = EmitterDefaults.retryFailedRequests

    /// Returns the number of events in the DB.
    var dbCount: Int {
        return Int(eventStore.count())
    }
    
    // MARK: - Initialization
    
    init(namespace: String,
         urlEndpoint: String,
         method: HttpMethodOptions? = nil,
         protocol: ProtocolOptions? = nil,
         customPostPath: String? = nil,
         requestHeaders: [String: String]? = nil,
         serverAnonymisation: Bool? = nil,
         eventStore: EventStore? = nil,
         builder: ((Emitter) -> (Void))? = nil) {
        self.namespace = namespace
        self.eventStore = eventStore ?? Emitter.defaultEventStore(namespace: namespace)
        
        let defaultNetworkConnection = DefaultNetworkConnection(
            urlString: urlEndpoint,
            httpMethod: method ?? EmitterDefaults.httpMethod,
            customPostPath: customPostPath
        )
        defaultNetworkConnection.requestHeaders = requestHeaders
        defaultNetworkConnection.serverAnonymisation = serverAnonymisation ?? EmitterDefaults.serverAnonymisation
        networkConnection = defaultNetworkConnection
        
        builder?(self)
        resumeTimer()
    }
    
    init(networkConnection: NetworkConnection,
         namespace: String,
         eventStore: EventStore? = nil,
         builder: ((Emitter) -> (Void))? = nil) {
        self.networkConnection = networkConnection
        self.namespace = namespace
        self.eventStore = eventStore ?? Emitter.defaultEventStore(namespace: namespace)
        
        builder?(self)
        resumeTimer()
    }
 
    deinit {
        pauseTimer()
    }
   
    private static func defaultEventStore(namespace: String) -> EventStore {
#if os(tvOS) || os(watchOS)
        return MemoryEventStore()
#else
        return SQLiteEventStore(namespace: namespace)
#endif
    }

    // MARK: - Pause/Resume methods

    func resumeTimer() {
        pauseTimer()

        self.timer = InternalQueue.startTimer(TimeInterval(kSPDefaultBufferTimeout)) { [weak self] in
            self?.flush()
        }
    }

    /// Suspends timer for periodically sending events to collector.
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Allows sending events to collector.
    func resumeEmit() {
        pausedEmit = false
        flush()
    }

    /// Suspends sending events to collector.
    func pauseEmit() {
        pausedEmit = true
    }

    /// Insert a Payload object into the buffer to be sent to collector.
    /// This method will add the payload to the database and flush (send all events).
    /// - Parameter eventPayload: A Payload containing a completed event to be added into the buffer.
    func addPayload(toBuffer eventPayload: Payload) {
        self.eventStore.addEvent(eventPayload)
        self.flush()
    }

    /// Empties the buffer of events using the respective HTTP request method.
    func flush() {
        if requestToStartSending() {
            self.attemptEmit()
        }
    }

    // MARK: - Control methods

    private func attemptEmit() {
        InternalQueue.onQueuePrecondition()
        
        let events = eventStore.emittableEvents(withQueryLimit: UInt(emitRange))
        if events.isEmpty {
            logDebug(message: "Database empty. Returning.")
            stopSending()
            return
        }
        
        let requests = buildRequests(fromEvents: events)
        
        let processResults: ([RequestResult]) -> Void = { sendResults in
            logVerbose(message: "Processing emitter results.")
            
            var successCount = 0
            var failedWillRetryCount = 0
            var failedWontRetryCount = 0
            var removableEvents: [Int64] = []
            
            for result in sendResults {
                let resultIndexArray = result.storeIds
                if result.isSuccessful {
                    successCount += resultIndexArray?.count ?? 0
                    if let array = resultIndexArray {
                        removableEvents.append(contentsOf: array)
                    }
                } else if result.shouldRetry(self.customRetryForStatusCodes, retryAllowed: self.retryFailedRequests) {
                    failedWillRetryCount += resultIndexArray?.count ?? 0
                } else {
                    failedWontRetryCount += resultIndexArray?.count ?? 0
                    if let array = resultIndexArray {
                        removableEvents.append(contentsOf: array)
                    }
                    logError(message: String(format: "Sending events to Collector failed with status %ld. Events will be dropped.", result.statusCode ?? -1))
                }
            }
            let allFailureCount = failedWillRetryCount + failedWontRetryCount
            
            _ = self.eventStore.removeEvents(withIds: removableEvents)
            
            logDebug(message: String(format: "Success Count: %d", successCount))
            logDebug(message: String(format: "Failure Count: %d", allFailureCount))
            
            if let callback = self.callback {
                if allFailureCount == 0 {
                    callback.onSuccess(withCount: successCount)
                } else {
                    callback.onFailure(withCount: allFailureCount, successCount: successCount)
                }
            }
            
            if failedWillRetryCount > 0 && successCount == 0 {
                logDebug(message: "Ending emitter run as all requests failed.")
                
                self.scheduleStopSending()
            } else {
                self.attemptEmit()
            }
        }
        
        emitAsync {
            let sendResults = self.networkConnection.sendRequests(requests)
            
            InternalQueue.async {
                processResults(sendResults)
            }
        }
    }

    private func buildRequests(fromEvents events: [EmitterEvent]) -> [Request] {
        var requests: [Request] = []
        
        let sendingTime = Utilities.getTimestamp()
        let byteLimit = method == .get ? byteLimitGet : byteLimitPost

        if method == .get {
            for event in events {
                let payload = event.payload
                addSendingTime(to: payload, timestamp: sendingTime)
                let oversize = isOversize(payload, byteLimit: byteLimit)
                let request = Request(payload: payload, emitterEventId: event.storeId, oversize: oversize)
                requests.append(request)
            }
        } else {
            var i = 0
            while i < events.count {
                var eventArray: [Payload] = []
                var indexArray: [Int64] = []

                let iUntil = min(i + bufferOption.rawValue, events.count)
                for j in i..<iUntil {
                    let event = events[j]

                    let payload = event.payload
                    let emitterEventId = event.storeId
                    addSendingTime(to: payload, timestamp: sendingTime)

                    if isOversize(payload, byteLimit: byteLimit) {
                        let request = Request(payload: payload, emitterEventId: emitterEventId, oversize: true)
                        requests.append(request)
                    } else if isOversize(payload, byteLimit: byteLimit, previousPayloads: eventArray) {
                        let request = Request(payloads: eventArray, emitterEventIds: indexArray)
                        requests.append(request)

                        // Clear collection and build a new POST
                        eventArray = []
                        indexArray = []

                        // Build and store the request
                        eventArray.append(payload)
                        indexArray.append(emitterEventId)
                    } else {
                        // Add event to collections
                        eventArray.append(payload)
                        indexArray.append(emitterEventId)
                    }
                }

                // Check if all payloads have been processed
                if eventArray.count != 0 {
                    let request = Request(payloads: eventArray, emitterEventIds: indexArray)
                    requests.append(request)
                }
                i += bufferOption.rawValue
            }
        }
        return requests
    }

    private func isOversize(_ payload: Payload, byteLimit: Int, previousPayloads: [Payload] = []) -> Bool {
        var totalByteSize = payload.byteSize
        for previousPayload in previousPayloads {
            totalByteSize += previousPayload.byteSize
        }
        let wrapperBytes = previousPayloads.count > 0 ? (previousPayloads.count + POST_WRAPPER_BYTES) : 0
        return totalByteSize + wrapperBytes > byteLimit
    }

    private func addSendingTime(to payload: Payload, timestamp: NSNumber) {
        payload.addValueToPayload(String(format: "%lld", timestamp.int64Value), forKey: kSPSentTimestamp)
    }
    
    private func requestToStartSending() -> Bool {
        if !isSending && !pausedEmit {
            isSending = true
            return true
        } else {
            return false
        }
    }
    
    private func scheduleStopSending() {
        InternalQueue.asyncAfter(TimeInterval(5)) { [weak self] in
            self?.stopSending()
        }
    }
    
    private func stopSending() {
        isSending = false
    }
    
    // MARK: - dispatch queues
    
    private let emitQueue = DispatchQueue(label: "snowplow.emitter")

    private func emitAsync(_ callback: @escaping () -> Void) {
        emitQueue.async(execute: callback)
    }
}
