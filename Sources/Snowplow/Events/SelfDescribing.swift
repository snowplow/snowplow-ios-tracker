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

/// A self-describing event.
@objc(SPSelfDescribing)
public class SelfDescribing: SelfDescribingAbstract {
    @objc
    public convenience init(eventData: SelfDescribingJson) {
        self.init(schema: eventData.schema, payload: eventData.data)
    }

    @objc
    public init(schema: String, payload: [String : Any]) {
        self._schema = schema
        self._payload = payload
    }
    
    private var _schema: String
    override var schema: String {
        get { return _schema }
        set { _schema = newValue }
    }
    
    private var _payload: [String : Any]
    override var payload: [String : Any] {
        get { return _payload }
        set {
            _payload = newValue
        }
    }
    
    var eventData: SelfDescribingJson {
        set {
            schema = newValue.schema
            payload = newValue.data
        }
        get {
            return SelfDescribingJson(schema: schema, andDictionary: payload)
        }
    }
}
