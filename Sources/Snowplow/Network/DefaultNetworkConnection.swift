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

@objc(SPDefaultNetworkConnection)
public class DefaultNetworkConnection: NSObject, NetworkConnection {
    private var _protocol: ProtocolOptions = .https
    // The protocol for connection to the collector
    @objc
    public var `protocol`: ProtocolOptions {
        get {
            return _protocol
        }
        set {
            _protocol = newValue
            if builderFinished { setup() }
        }
    }

    private var _urlString: String
    /// The collector endpoint.
    @objc
    public var urlString: String {
        get {
            return urlEndpoint?.absoluteString ?? _urlString
        }
        set {
            _urlString = newValue
            if builderFinished { setup() }
        }
    }
    @objc
    private(set) public var urlEndpoint: URL?

    private var _httpMethod: HttpMethodOptions = .post
    /// HTTP method, should be .get or .post.
    @objc
    public var httpMethod: HttpMethodOptions {
        get {
            return _httpMethod
        }
        set(method) {
            _httpMethod = method
            if builderFinished && urlEndpoint != nil {
                setup()
            }
        }
    }

    private var _emitThreadPoolSize = 15
    /// The number of threads used by the emitter.
    @objc
    public var emitThreadPoolSize: Int {
        get {
            return _emitThreadPoolSize
        }
        set(emitThreadPoolSize) {
            self._emitThreadPoolSize = emitThreadPoolSize
            if dataOperationQueue.maxConcurrentOperationCount != emitThreadPoolSize {
                dataOperationQueue.maxConcurrentOperationCount = emitThreadPoolSize
            }
        }
    }
    /// Maximum event size for a GET request.
    public var byteLimitGet: Int = 40000
    /// Maximum event size for a POST request.
    @objc
    public var byteLimitPost = 40000
    /// A custom path that is used on the endpoint to send requests.
    @objc
    public var customPostPath: String?
    /// Custom headers (key, value) for http requests.
    @objc
    public var requestHeaders: [String : String]?
    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`
    @objc
    public var serverAnonymisation = false
    private var dataOperationQueue = OperationQueue()
    private var builderFinished = false
    
    @objc
    public init(urlString: String,
                httpMethod: HttpMethodOptions = EmitterDefaults.httpMethod,
                protocol: ProtocolOptions = EmitterDefaults.httpProtocol,
                customPostPath: String? = nil) {
        self._urlString = urlString
        super.init()
        self.httpMethod = httpMethod
        self.protocol = `protocol`
        self.customPostPath = customPostPath
        setup()
    }

    // MARK: - Implement SPNetworkConnection protocol
    
    private func setup() {
        // Decode url to extract protocol
        let url = URL(string: _urlString)
        var endpoint = _urlString
        if url?.scheme == "https" {
            `protocol` = .https
        } else if url?.scheme == "http" {
            `protocol` = .http
        } else {
            `protocol` = .https
            endpoint = "https://\(_urlString)"
        }

        // Configure
        let urlPrefix = `protocol` == .http ? "http://" : "https://"
        var urlSuffix = _httpMethod == .get ? kSPEndpointGet : kSPEndpointPost
        if _httpMethod == .post {
            if let customPostPath = customPostPath { urlSuffix = customPostPath }
        }

        // Remove trailing slashes from endpoint to avoid double slashes when appending path
        endpoint = endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        urlEndpoint = URL(string: endpoint)?.appendingPathComponent(urlSuffix)

        // Log
        if urlEndpoint?.scheme != nil && urlEndpoint?.host != nil {
            logDebug(message: "Emitter URL created successfully '\(urlEndpoint?.absoluteString ?? "-")'")
        } else {
            logDebug(message: "Invalid emitter URL: '\(urlEndpoint?.absoluteString ?? "-")'")
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(endpoint, forKey: kSPErrorTrackerUrl)
        userDefaults.set(urlSuffix, forKey: kSPErrorTrackerProtocol)
        userDefaults.set(urlPrefix, forKey: kSPErrorTrackerMethod)

        builderFinished = true
    }

    @objc
    public func sendRequests(_ requests: [Request]) -> [RequestResult] {
        var results: [RequestResult] = []

        for request in requests {
            let urlRequest = _httpMethod == .get
                ? buildGet(request)
                : buildPost(request)

            dataOperationQueue.addOperation({
                //source: https://forums.developer.apple.com/thread/11519
                var httpResponse: HTTPURLResponse? = nil
                var connectionError: Error? = nil
                var sem: DispatchSemaphore

                sem = DispatchSemaphore(value: 0)

                URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
                    connectionError = error
                    httpResponse = urlResponse as? HTTPURLResponse
                    sem.signal()
                }.resume()

                let _ = sem.wait(timeout: .distantFuture)
                var statusCode: NSNumber?
                if let httpResponse = httpResponse { statusCode = NSNumber(value: httpResponse.statusCode) }

                let result = RequestResult(statusCode: statusCode, oversize: request.oversize, storeIds: request.emitterEventIds)
                if !result.isSuccessful {
                    logError(message: "Connection error: " + (connectionError?.localizedDescription ?? "-"))
                }

                objc_sync_enter(self)
                results.append(result)
                objc_sync_exit(self)
            })
        }
        dataOperationQueue.waitUntilAllOperationsAreFinished()
        return results
    }

    // MARK: - Private methods

    func buildPost(_ request: Request) -> URLRequest {
        var requestData: Data? = nil
        do {
            requestData = try JSONSerialization.data(withJSONObject: request.payload?.dictionary ?? [:], options: [])
        } catch {
        }
        let url = URL(string: urlEndpoint!.absoluteString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("\(NSNumber(value: requestData?.count ?? 0).stringValue)", forHTTPHeaderField: "Content-Length")
        urlRequest.setValue(kSPAcceptContentHeader, forHTTPHeaderField: "Accept")
        urlRequest.setValue(kSPContentTypeHeader, forHTTPHeaderField: "Content-Type")
        if serverAnonymisation {
            urlRequest.setValue("*", forHTTPHeaderField: "SP-Anonymous")
        }
        if let requestHeaders = requestHeaders {
            applyValuesAndHeaderFields(requestHeaders, to: &urlRequest)
        }
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = requestData
        return urlRequest
    }

    func buildGet(_ request: Request) -> URLRequest {
        let payload = request.payload?.dictionary ?? [:]
        let url = "\(urlEndpoint!.absoluteString)?\(Utilities.urlEncode(payload))"
        let anUrl = URL(string: url)!
        var urlRequest = URLRequest(url: anUrl)
        urlRequest.setValue(kSPAcceptContentHeader, forHTTPHeaderField: "Accept")
        if serverAnonymisation {
            urlRequest.setValue("*", forHTTPHeaderField: "SP-Anonymous")
        }
        if let requestHeaders = requestHeaders {
            applyValuesAndHeaderFields(requestHeaders, to: &urlRequest)
        }
        urlRequest.httpMethod = "GET"
        return urlRequest
    }

    func applyValuesAndHeaderFields(_ requestHeaders: [String : String], to request: inout URLRequest) {
        (requestHeaders as NSDictionary).enumerateKeysAndObjects({ key, obj, stop in
            if let key = key as? String, let obj = obj as? String {
                request.setValue(obj, forHTTPHeaderField: key)
            }
        })
    }
}
