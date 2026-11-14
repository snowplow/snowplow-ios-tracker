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

let kSPSignalsUserIdAttributeKey = "client_session_user_id"
let kSPSignalsSessionIdAttributeKey = "client_session_session_id"

/// URL building and session setup shared by Signals reads and the interventions stream.
enum SignalsNetworking {
    /// URL protocol classes to register on Signals URL sessions; set by tests to mock requests.
    static var protocolClasses: [AnyClass]?

    /// Characters left unescaped in path segments and query items (RFC 3986 unreserved).
    private static let unreserved = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    static func encode(_ value: String) -> String {
        return value.addingPercentEncoding(withAllowedCharacters: unreserved) ?? value
    }

    /// Builds `{baseUrl}{path}?{query}`, percent-encoding every query name and value.
    static func url(baseUrl: String, path: String, query: [(String, String)]) -> URL? {
        let queryString = query.map { "\(encode($0.0))=\(encode($0.1))" }.joined(separator: "&")
        return URL(string: baseUrl + path + (queryString.isEmpty ? "" : "?" + queryString))
    }

    static func serviceUrl(baseUrl: String, service: String, attributeKey: String, identifier: String) -> URL? {
        return url(baseUrl: baseUrl,
                   path: "/api/v1/services/" + encode(service),
                   query: [(attributeKey, identifier)])
    }

    /// An ephemeral session: no cookies, credentials or cache.
    static func makeSession(timeout: TimeInterval,
                            delegate: URLSessionDelegate? = nil,
                            delegateQueue: OperationQueue? = nil) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.urlCredentialStorage = nil
        configuration.timeoutIntervalForRequest = timeout
        if let protocolClasses = protocolClasses {
            configuration.protocolClasses = protocolClasses + (configuration.protocolClasses ?? [])
        }
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }

    /// Reads the `error` message from a Signals error response body, or describes the status code.
    static func errorMessage(data: Data?, statusCode: Int) -> String {
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["error"] as? String {
            return message
        }
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}
