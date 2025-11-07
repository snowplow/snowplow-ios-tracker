//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

    /// Creates a self-describing event using data represented as an Encodable struct.
    /// NOTE: The data should be serializable to JSON using the JSONSerialization class in Foundation. An exception will be thrown if the data is not serializable. To make sure your data is serializable, you can use the `JSONSerialization.isValidJSONObject` function.
    /// - Parameters:
    ///   - schema: A valid schema URI.
    ///   - payload: Payload for the event.
    /// - Returns: A SelfDescribing event.
    @objc
    public init(schema: String, payload: [String : Any]) {
        self._schema = schema
        self._payload = payload
    }
    
    /// Creates a self-describing event using data represented as an Encodable struct.
    /// 
    /// The provided Encodable data is encoded to JSON using the specified JSONEncoder,
    /// then converted to a dictionary representation suitable for tracking.
    /// 
    /// - Parameters:
    ///   - schema: A valid schema URI that describes the structure of the data.
    ///   - encoder: The JSONEncoder to use for encoding the data. Defaults to a new JSONEncoder instance.
    ///   - data: Data represented using an Encodable struct that will be encoded to JSON.
    /// - Throws: 
    ///   - `EncodingError` if the data cannot be encoded by the JSONEncoder.
    ///   - `PayloadError.jsonSerializationToDictionaryFailed` if the encoded JSON cannot be converted to a dictionary.
    /// - Returns: A SelfDescribing event containing the encoded data.
    public convenience init<T: Encodable>(schema: String, encoder: JSONEncoder = JSONEncoder(), data: T) throws {
        let data = try encoder.encode(data)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let dict = jsonObject as? [String: Any] else {
            throw PayloadError.jsonSerializationToDictionaryFailed
        }
        
        self.init(schema: schema, payload: dict)
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
