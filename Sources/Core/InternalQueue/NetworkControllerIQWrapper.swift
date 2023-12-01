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

class NetworkControllerIQWrapper: NetworkController {
    
    private let controller: NetworkController
    
    init(controller: NetworkController) {
        self.controller = controller
    }
    
    // MARK: - Properties

    var endpoint: String? {
        get { return InternalQueue.sync { controller.endpoint } }
        set { InternalQueue.sync { controller.endpoint = newValue } }
    }

    var method: HttpMethodOptions {
        get { return InternalQueue.sync { controller.method } }
        set { InternalQueue.sync { controller.method = newValue } }
    }

    var customPostPath: String? {
        get { return InternalQueue.sync { controller.customPostPath } }
        set { InternalQueue.sync { controller.customPostPath = newValue } }
    }

    var requestHeaders: [String : String]? {
        get { return InternalQueue.sync { controller.requestHeaders } }
        set { InternalQueue.sync { controller.requestHeaders = newValue } }
    }

}
