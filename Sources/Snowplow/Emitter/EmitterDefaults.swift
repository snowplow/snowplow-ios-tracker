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

public class EmitterDefaults {
    public private(set) static var httpMethod: HttpMethodOptions = .post
    public private(set) static var httpProtocol: ProtocolOptions = .https
    public private(set) static var emitRange = 150
    public private(set) static var emitThreadPoolSize = 15
    public private(set) static var byteLimitGet = 40000
    public private(set) static var byteLimitPost = 40000
    public private(set) static var serverAnonymisation = false
    public private(set) static var bufferOption: BufferOption = .single
    public private(set) static var retryFailedRequests = true
}
