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

@objc(SPRequestResult)
public class RequestResult: NSObject {
    /// Returns the HTTP status code from Collector.
    public private(set) var statusCode: Int?
    /// Was the request oversize
    @objc
    public private(set) var isOversize: Bool
    /// Returns the stored index array, needed to remove the events after sending.
    @objc
    public private(set) var storeIds: [Int64]?

    @objc
    public convenience override init() {
        self.init(statusCode: -1, oversize: false, storeIds: [])
    }

    /// Creates a request result object
    /// - Parameters:
    ///   - statusCode: HTTP status code from collector response
    ///   - storeIds: the event indexes in the database
    @objc
    public init(statusCode: NSNumber?, oversize isOversize: Bool, storeIds: [Int64]?) {
        self.statusCode = statusCode?.intValue
        self.isOversize = isOversize
        self.storeIds = storeIds
    }
    
    /// - Returns: Whether the events were successfuly sent to the Collector.
    @objc
    public var isSuccessful: Bool {
        if let statusCode = statusCode {
            return statusCode >= 200 && statusCode < 300
        }
        return false
    }

    /// - Parameter customRetryForStatusCodes: mapping of custom retry rules for HTTP status codes in Collector response.
    /// - Returns: Whether sending the events to the Collector should be retried.
    func shouldRetry(_ customRetryForStatusCodes: [Int : Bool]?, retryAllowed: Bool) -> Bool {
        // don't retry if successful
        if isSuccessful {
            return false
        }
        
        // don't retry if retries are not allowed
        if !retryAllowed {
            return false
        }

        // don't retry if request is larger than max byte limit
        if isOversize {
            return false
        }

        // status code has a custom retry rule
        if let statusCode = statusCode {
            if let retryRule = customRetryForStatusCodes?[statusCode] {
                return retryRule
            }
            
            // retry if status code is not in the list of no-retry status codes
            let dontRetryStatusCodes = [400, 401, 403, 410, 422]
            return !dontRetryStatusCodes.contains(statusCode)
        }
        return true
    }
}
