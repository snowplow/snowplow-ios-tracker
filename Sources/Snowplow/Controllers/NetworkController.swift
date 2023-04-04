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

@objc(SPNetworkController)
public protocol NetworkController: AnyObject {
    /// URL used to send events to the collector.
    @objc
    var endpoint: String? { get set }
    /// Method used to send events to the collector.
    @objc
    var method: HttpMethodOptions { get set }
    /// A custom path which will be added to the endpoint URL to specify the
    /// complete URL of the collector when paired with the POST method.
    @objc
    var customPostPath: String? { get set }
    /// Custom headers for http requests.
    @objc
    var requestHeaders: [String : String]? { get set }
}
