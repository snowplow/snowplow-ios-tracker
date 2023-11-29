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
@testable import SnowplowTracker

class MockNetworkConnection: NSObject, NetworkConnection {
    var statusCode = 0

    private var _httpMethod: HttpMethodOptions?
    var httpMethod: HttpMethodOptions {
        return _httpMethod!
    }
    var previousResults: [[RequestResult]] = []
    var previousRequests: [[Request]] = []
    var urlEndpoint: URL? {
        return (URL(string: "http://fake-url.com"))!
    }

    var sendingCount: Int {
        return previousResults.count
    }

    init(requestOption httpMethod: HttpMethodOptions, statusCode: Int) {
        super.init()
        self._httpMethod = httpMethod
        self.statusCode = statusCode
    }

    func sendRequests(_ requests: [Request]) -> [RequestResult] {
        var requestResults: [RequestResult] = []
        for request in requests {
            let result = RequestResult(statusCode: NSNumber(value: statusCode), oversize: request.oversize, storeIds: request.emitterEventIds)
            logVerbose(message: "Sent \(String(describing: request.emitterEventIds)) with success \(result.isSuccessful ? "YES" : "NO")")
            requestResults.append(result)
        }
        previousRequests.append(requests)
        previousResults.append(requestResults)
        return requestResults
    }
    
    func clear() {
        previousRequests = []
        previousResults = []
    }
}
