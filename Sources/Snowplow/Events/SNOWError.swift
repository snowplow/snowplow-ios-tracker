//
//  SNOWError.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

@objc(SPSNOWError)
public class SNOWError: SelfDescribingAbstract {
    @objc
    public var message: String
    @objc
    public var name: String?
    @objc
    public var stackTrace: String?
    
    @objc
    public init(message: String) {
        self.message = message
    }
    
    override public var schema: String {
        return kSPErrorSchema
    }

    override public var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPErrorMessage] = message as NSObject
        payload[kSPErrorStackTrace] = stackTrace as NSObject?
        payload[kSPErrorName] = name as NSObject?
        payload[kSPErrorLanguage] = "SWIFT" as NSObject
        return payload
    }
}
