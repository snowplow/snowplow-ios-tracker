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

class NetworkControllerImpl: Controller, NetworkController {
    private var requestCallback: RequestCallback?

    // MARK: - Properties

    var endpoint: String? {
        get {
            return emitter.urlEndpoint
        }
        set {
            emitter.urlEndpoint = newValue
        }
    }

    var method: HttpMethodOptions {
        get {
            return emitter.method
        }
        set {
            emitter.method = newValue
        }
    }

    var customPostPath: String? {
        get {
            return emitter.customPostPath
        }
        set {
            dirtyConfig.customPostPath = newValue
            emitter.customPostPath = newValue
        }
    }

    var requestHeaders: [String : String]? {
        get {
            return emitter.requestHeaders
        }
        set {
            dirtyConfig.requestHeaders = requestHeaders
            emitter.requestHeaders = newValue
        }
    }

    // MARK: - Private methods

    private var emitter: Emitter {
        return serviceProvider.tracker.emitter
    }

    private var dirtyConfig: NetworkConfiguration {
        return serviceProvider.networkConfiguration
    }
}
