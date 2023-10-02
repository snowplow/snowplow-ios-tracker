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

class Emitter: NSObject, EmitterEventProcessing {
    
    private var timer: Timer?
    private var dataOperationQueue: OperationQueue = OperationQueue()
    private var builderFinished = false
    
    private var sendingCheck = SendingCheck()
    /// Whether the emitter is currently sending.
    var isSending: Bool { return sendingCheck.sending }

    private var _urlEndpoint: String?
    /// Collector endpoint.
    var urlEndpoint: String? {
        get {
            if builderFinished {
                return networkConnection?.urlEndpoint?.absoluteString
            }
            return _urlEndpoint
        }
        set {
            _urlEndpoint = newValue
            if builderFinished {
                setupNetworkConnection()
            }
        }
    }

    private var _namespace: String?
    var namespace: String? {
        get {
            return _namespace
        }
        set(namespace) {
            _namespace = namespace
            if builderFinished && eventStore == nil {
                #if os(tvOS) || os(watchOS)
                eventStore = MemoryEventStore()
                #else
                eventStore = SQLiteEventStore(namespace: _namespace)
                #endif
            }
        }
    }

    private var _method: HttpMethodOptions = EmitterDefaults.httpMethod
    /// Chosen HTTP method - .get or .post.
    var method: HttpMethodOptions {
        get {
            return _method
        }
        set(method) {
            _method = method
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }
    
    private var _protocol: ProtocolOptions = EmitterDefaults.httpProtocol
    /// Security of requests - ProtocolHttp or ProtocolHttps.
    var `protocol`: ProtocolOptions {
        get {
            return _protocol
        }
        set(`protocol`) {
            _protocol = `protocol`
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }
    private var _bufferOption: BufferOption = EmitterDefaults.bufferOption
    /// Buffer option
    var bufferOption: BufferOption {
        get {
            return _bufferOption
        }
        set(bufferOption) {
            if !isSending {
                _bufferOption = bufferOption
            }
        }
    }
    
    private weak var _callback: RequestCallback?
    /// Callbacks supplied with number of failures and successes of sent events.
    var callback: RequestCallback? {
        get {
            return _callback
        }
        set(callback) {
            _callback = callback
        }
    }
    
    private var _emitRange = EmitterDefaults.emitRange
    /// Number of events retrieved from the database when needed.
    var emitRange: Int {
        get {
            return _emitRange
        }
        set(emitRange) {
            if emitRange > 0 {
                _emitRange = emitRange
            }
        }
    }
    
    private var _emitThreadPoolSize = EmitterDefaults.emitThreadPoolSize
    /// Number of threads used for emitting events.
    var emitThreadPoolSize: Int {
        get {
            return _emitThreadPoolSize
        }
        set(emitThreadPoolSize) {
            if emitThreadPoolSize > 0 {
                _emitThreadPoolSize = emitThreadPoolSize
                if dataOperationQueue.maxConcurrentOperationCount != emitThreadPoolSize {
                    dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize
                }
                if builderFinished && networkConnection != nil {
                    setupNetworkConnection()
                }
            }
        }
    }
    
    private var _byteLimitGet = EmitterDefaults.byteLimitGet
    /// Byte limit for GET requests.
    var byteLimitGet: Int {
        get {
            return _byteLimitGet
        }
        set(byteLimitGet) {
            _byteLimitGet = byteLimitGet
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }
    
    private var _byteLimitPost = EmitterDefaults.byteLimitPost
    /// Byte limit for POST requests.
    var byteLimitPost: Int {
        get {
            return _byteLimitPost
        }
        set(byteLimitPost) {
            _byteLimitPost = byteLimitPost
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }

    private var _serverAnonymisation = EmitterDefaults.serverAnonymisation
    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`.
    var serverAnonymisation: Bool {
        get {
            return _serverAnonymisation
        }
        set(serverAnonymisation) {
            _serverAnonymisation = serverAnonymisation
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }

    private var _customPostPath: String?
    /// Custom endpoint path for POST requests.
    var customPostPath: String? {
        get {
            return _customPostPath
        }
        set(customPath) {
            _customPostPath = customPath
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }

    /// Custom header requests.
    private var _requestHeaders: [String : String]?
    var requestHeaders: [String : String]? {
        get {
            return _requestHeaders
        }
        set(requestHeaders) {
            _requestHeaders = requestHeaders
            if builderFinished && networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }

    private var _networkConnection: NetworkConnection?
    /// Custom NetworkConnection istance to handle connection outside the emitter.
    var networkConnection: NetworkConnection? {
        get {
            return _networkConnection
        }
        set(networkConnection) {
            _networkConnection = networkConnection
            if builderFinished && _networkConnection != nil {
                setupNetworkConnection()
            }
        }
    }
    
    private var _eventStore: EventStore?
    var eventStore: EventStore? {
        get {
            return _eventStore
        }
        set(eventStore) {
            if !builderFinished || self.eventStore == nil || self.eventStore?.count() == 0 {
                _eventStore = eventStore
            }
        }
    }
    
    /// Custom retry rules for HTTP status codes.
    private var _customRetryForStatusCodes: [Int : Bool] = [:]
    var customRetryForStatusCodes: [Int : Bool]? {
        get {
            return _customRetryForStatusCodes
        }
        set(customRetryForStatusCodes) {
            _customRetryForStatusCodes = customRetryForStatusCodes ?? [:]
        }
    }
    
    /// Whether retrying failed requests is allowed
    var retryFailedRequests: Bool = EmitterDefaults.retryFailedRequests

    /// Returns the number of events in the DB.
    var dbCount: Int {
        return Int(eventStore?.count() ?? 0)
    }
    
    // MARK: - Initialization
    
    init(urlEndpoint: String,
         builder: ((Emitter) -> (Void))) {
        super.init()
        self._urlEndpoint = urlEndpoint
        
        builder(self)
        setup()
   }
    
    init(networkConnection: NetworkConnection,
         builder: ((Emitter) -> (Void))) {
        super.init()
        self._networkConnection = networkConnection
        
        builder(self)
        setup()
    }

    private func setup() {
        dataOperationQueue.maxConcurrentOperationCount = emitThreadPoolSize
        setupNetworkConnection()
        resumeTimer()
        builderFinished = true
    }

    private func setupNetworkConnection() {
        if !builderFinished && networkConnection != nil {
            return
        }
        if let url = _urlEndpoint {
            var endpoint = "\(url)"
            if !endpoint.hasPrefix("http") {
                let `protocol` = self.protocol == .https ? "https://" : "http://"
                endpoint = `protocol` + endpoint
            }
            let defaultNetworkConnection = DefaultNetworkConnection(
                urlString: endpoint,
                httpMethod: method,
                customPostPath: customPostPath
            )
            defaultNetworkConnection.requestHeaders = requestHeaders
            defaultNetworkConnection.emitThreadPoolSize = emitThreadPoolSize
            defaultNetworkConnection.byteLimitGet = byteLimitGet
            defaultNetworkConnection.byteLimitPost = byteLimitPost
            defaultNetworkConnection.serverAnonymisation = serverAnonymisation
            _networkConnection = defaultNetworkConnection
        }
    }

    // MARK: - Pause/Resume methods

    func resumeTimer() {
        weak var weakSelf = self

        if timer != nil {
            pauseTimer()
        }

        DispatchQueue.main.async {
            weakSelf?.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(kSPDefaultBufferTimeout), repeats: true) { [weak self] timer in
                self?.flush()
            }
        }
    }

    /// Suspends timer for periodically sending events to collector.
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Allows sending events to collector.
    func resumeEmit() {
        sendingCheck.pausedEmit = false
        flush()
    }

    /// Suspends sending events to collector.
    func pauseEmit() {
        sendingCheck.pausedEmit = true
    }

    /// Insert a Payload object into the buffer to be sent to collector.
    /// This method will add the payload to the database and flush (send all events).
    /// - Parameter eventPayload: A Payload containing a completed event to be added into the buffer.
    func addPayload(toBuffer eventPayload: Payload) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            self?.eventStore?.addEvent(eventPayload)
            self?.flush()
        }
    }

    /// Empties the buffer of events using the respective HTTP request method.
    func flush() {
        if Thread.isMainThread {
            DispatchQueue.global(qos: .default).async { [self] in
                sendGuard()
            }
        } else {
            sendGuard()
        }
    }

    // MARK: - Control methods

    private func sendGuard() {
        if sendingCheck.requestToStartSending() {
            objc_sync_enter(self)
            attemptEmit()
            objc_sync_exit(self)
            sendingCheck.sending = false
        }
    }
    
    private func attemptEmit() {
        guard let eventStore = eventStore else { return }
        if eventStore.count() == 0 {
            logDebug(message: "Database empty. Returning.")
            return
        }

        let events = eventStore.emittableEvents(withQueryLimit: UInt(emitRange))
        let requests = buildRequests(fromEvents: events)
        let sendResults = networkConnection?.sendRequests(requests)

        logVerbose(message: "Processing emitter results.")

        var successCount = 0
        var failedWillRetryCount = 0
        var failedWontRetryCount = 0
        var removableEvents: [Int64] = []

        for result in sendResults ?? [] {
            let resultIndexArray = result.storeIds
            if result.isSuccessful {
                successCount += resultIndexArray?.count ?? 0
                if let array = resultIndexArray {
                    removableEvents.append(contentsOf: array)
                }
            } else if result.shouldRetry(customRetryForStatusCodes, retryAllowed: retryFailedRequests) {
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

        let _ = eventStore.removeEvents(withIds: removableEvents)

        logDebug(message: String(format: "Success Count: %d", successCount))
        logDebug(message: String(format: "Failure Count: %d", allFailureCount))

        if callback != nil {
            if allFailureCount == 0 {
                callback?.onSuccess(withCount: successCount)
            } else {
                callback?.onFailure(withCount: allFailureCount, successCount: successCount)
            }
        }

        if failedWillRetryCount > 0 && successCount == 0 {
            logDebug(message: "Ending emitter run as all requests failed.")
            Thread.sleep(forTimeInterval: 5)
            return
        } else {
            self.attemptEmit()
        }
    }

    private func buildRequests(fromEvents events: [EmitterEvent]) -> [Request] {
        var requests: [Request] = []
        guard let networkConnection = networkConnection else { return requests }
        
        let sendingTime = Utilities.getTimestamp()
        let httpMethod = networkConnection.httpMethod

        if httpMethod == .get {
            for event in events {
                let payload = event.payload
                addSendingTime(to: payload, timestamp: sendingTime)
                let oversize = isOversize(payload)
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

                    if isOversize(payload) {
                        let request = Request(payload: payload, emitterEventId: emitterEventId, oversize: true)
                        requests.append(request)
                    } else if isOversize(payload, previousPayloads: eventArray) {
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

    private func isOversize(_ payload: Payload) -> Bool {
        return isOversize(payload, previousPayloads: [])
    }

    private func isOversize(_ payload: Payload, previousPayloads: [Payload]) -> Bool {
        let byteLimit = networkConnection?.httpMethod == .get ? byteLimitGet : byteLimitPost
        return isOversize(payload, byteLimit: byteLimit, previousPayloads: previousPayloads)
    }

    private func isOversize(_ payload: Payload, byteLimit: Int, previousPayloads: [Payload]) -> Bool {
        var totalByteSize = payload.byteSize
        for previousPayload in previousPayloads {
            totalByteSize += previousPayload.byteSize
        }
        let wrapperBytes = previousPayloads.count > 0 ? (previousPayloads.count + POST_WRAPPER_BYTES) : 0
        return totalByteSize + wrapperBytes > byteLimit
    }

    func addSendingTime(to payload: Payload, timestamp: NSNumber) {
        payload.addValueToPayload(String(format: "%lld", timestamp.int64Value), forKey: kSPSentTimestamp)
    }

    deinit {
        pauseTimer()
    }
}

fileprivate class SendingCheck {
    private var _sending = false
    var sending: Bool {
        get {
            return lock { return _sending }
        }
        set {
            lock { _sending = newValue }
        }
    }
    
    private var _pausedEmit = false
    var pausedEmit: Bool {
        get {
            return lock { return _pausedEmit }
        }
        set {
            lock { _pausedEmit = newValue }
        }
    }
    
    func requestToStartSending() -> Bool {
        return lock {
            if !_sending && !_pausedEmit {
                _sending = true
                return true
            } else {
                return false
            }
        }
    }
    
    private func lock<T>(closure: () -> T) -> T {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return closure()
    }
}
