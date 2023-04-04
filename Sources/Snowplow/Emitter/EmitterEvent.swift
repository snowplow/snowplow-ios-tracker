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

@objc(SPEmitterEvent)
public class EmitterEvent: NSObject {
    private(set) var payload: Payload
    private(set) var storeId: Int64

    init(payload: Payload, storeId: Int64) {
        self.payload = payload
        self.storeId = storeId
    }

    @objc
    override public var description: String {
        return String(format: "EmitterEvent{ %lld }", storeId)
    }
}
