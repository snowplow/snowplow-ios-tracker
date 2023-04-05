//
//  FocalMeterConfiguration.swift
//  Snowplow
//
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
//
//  License: Apache License Version 2.0
//

import Foundation

/// This configuration tells the tracker to send requests with the user ID in session context entity
/// to a Kantar endpoint used with FocalMeter.
/// The request is made when the first event with a new user ID is tracked.
/// The requests are only made if session context is enabled (default).
@objc(SPFocalMeterConfiguration)
public class FocalMeterConfiguration: NSObject, PluginAfterTrackCallable, PluginIdentifiable, ConfigurationProtocol {
    public private(set) var identifier = "KantarFocalMeter"
    public private(set) var afterTrackConfiguration: PluginAfterTrackConfiguration?
    
    /// URL of the Kantar endpoint to send the requests to
    public private(set) var kantarEndpoint: String
    
    /// Callback to process user ID before sending it in a request. This may be used to apply hashing to the value.
    public private(set) var processUserId: ((String) -> String)? = nil
    
    private var lastUserId: String?

    /// Creates a configuration for the Kantar FocalMeter.
    /// - Parameters:
    ///    - endpoint: URL of the Kantar endpoint to send the requests to
    ///    - processUserId: Callback to process user ID before sending it in a request. This may be used to apply hashing to the value.
    @objc
    public init(kantarEndpoint: String, processUserId: ((String) -> String)? = nil) {
        self.kantarEndpoint = kantarEndpoint
        super.init()

        self.afterTrackConfiguration = PluginAfterTrackConfiguration { event in
            let session = event.entities.first { entity in
                entity.schema == kSPSessionContextSchema
            }
            if let userId = session?.data[kSPSessionUserId] as? String {
                if self.shouldUpdate(userId) {
                    if let processUserId = processUserId {
                        self.makeRequest(userId: processUserId(userId))
                    } else {
                        self.makeRequest(userId: userId)
                    }
                }
            }
        }
    }

    private func shouldUpdate(_ newUserId: String) -> Bool {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if lastUserId == nil || newUserId != lastUserId {
            lastUserId = newUserId
            return true
        }
        return false
    }

    private func makeRequest(userId: String) {
        var components = URLComponents(string: kantarEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "vendor", value: "snowplow"),
            URLQueryItem(name: "cs_fpid", value: userId),
            URLQueryItem(name: "c12", value: "not_set"),
        ]

        guard let url = components?.url else {
            logError(message: "Failed to build URL to request Kantar endpoint")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logError(message: "Request to Kantar endpoint failed: \(error)")
            }
            else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    logDebug(message: "Request to Kantar endpoint sent with user ID: \(userId)")
                    return
                } else {
                    logError(message: "Request to Kantar endpoint was not successful")
                }
            }
        }
        task.resume()
    }
}
