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

/// @class SPSelfDescribingJson
/// The class that represents self-describing JSONs.
/// This class holds the information of a self-describing JSON.
/// - seealso: SPPayload
@objc(SPSelfDescribingJson)
open class SelfDescribingJson: NSObject {
    /// the schema URI for this self-describing JSON.
    @objc
    public var schema: String
    
    /// Data of the self-describing JSON.
    @objc
    public var data: [String : Any]

    /// Returns the internal NSDictionary of the self-describing JSON.
    /// - Returns: The self-describing JSON as an NSDictionary.
    @objc
    public var dictionary: [String : Any] {
        return SelfDescribingJson.dictionary(schema: schema, data: data)
    }

    /// Returns a string description of the internal dictionary.
    /// - Returns: The description of the dictionary.
    @objc
    override public var description: String {
        return dictionary.description
    }

    /// Initializes a newly allocated SPSelfDescribingJson.
    /// NOTE: The data should be serializable to JSON using the JSONSerialization class in Foundation. An exception will be thrown if the data is not serializable. To make sure your data is serializable, you can use the `JSONSerialization.isValidJSONObject` function.
    /// - Parameters:
    ///   - schema: A valid schema string.
    ///   - data: Data to set for data field of the self-describing JSON, should be an NSDictionary.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public init(schema: String, andData data: [String : Any]) {
        self.schema = schema
        self.data = data
        super.init()
    }

    /// Initializes a newly allocated SPSelfDescribingJson.
    /// NOTE: The data should be serializable to JSON using the JSONSerialization class in Foundation. An exception will be thrown if the data is not serializable. To make sure your data is serializable, you can use the `JSONSerialization.isValidJSONObject` function.
    /// - Parameters:
    ///   - schema: A valid schema string.
    ///   - data: Dictionary to set for data field of the self-describing JSON.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public convenience init(schema: String, andDictionary data: [String : Any]) {
        self.init(schema: schema, andData: data)
    }

    /// Initializes a newly allocated SPSelfDescribingJson.
    /// NOTE: The payload should be serializable to JSON using the JSONSerialization class in Foundation. An exception will be thrown if the data is not serializable. To make sure your data is serializable, you can use the `JSONSerialization.isValidJSONObject` function.
    /// - Parameters:
    ///   - schema: A valid schema string.
    ///   - data: Payload to set for data field of the self-describing JSON.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public convenience init(schema: String, andPayload payload: Payload) {
        self.init(schema: schema, andData: payload.dictionary)
    }

    /// Initializes a newly allocated SPSelfDescribingJson.
    /// NOTE: The data should be serializable to JSON using the JSONSerialization class in Foundation. An exception will be thrown if the data is not serializable. To make sure your data is serializable, you can use the `JSONSerialization.isValidJSONObject` function.
    /// - Parameters:
    ///   - schema: A valid schema URI.
    ///   - data: Self-describing JSON to set for data field of the self-describing JSON.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public convenience init(schema: String, andSelfDescribingJson data: SelfDescribingJson) {
        self.init(schema: schema, andData: data.dictionary)
    }
    
    /// Creates a self-describing JSON using data represented as an Encodable struct.
    /// 
    /// This convenience initializer allows you to create a SelfDescribingJson from any Encodable type.
    /// The provided Encodable data is encoded to JSON using the specified JSONEncoder,
    /// then converted to a dictionary representation for the self-describing JSON structure.
    /// 
    /// - Parameters:
    ///   - schema: A valid schema URI that describes the structure of the data.
    ///   - encoder: The JSONEncoder to use for encoding the data. Defaults to a new JSONEncoder instance.
    ///   - data: Data represented using an Encodable struct that will be encoded to JSON.
    /// - Throws: 
    ///   - `EncodingError` if the data cannot be encoded by the JSONEncoder.
    ///   - `PayloadError.jsonSerializationToDictionaryFailed` if the encoded JSON cannot be converted to a dictionary.
    /// - Returns: A SelfDescribingJson containing the encoded data.
    public convenience init<T: Encodable>(schema: String, encoder: JSONEncoder = JSONEncoder(), andEncodable data: T) throws {
        let data = try encoder.encode(data)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let dict = jsonObject as? [String: Any] else {
            throw PayloadError.jsonSerializationToDictionaryFailed
        }
        
        self.init(schema: schema, andData: dict)
    }

    /// Sets the data field of the self-describing JSON.
    /// - Parameter data: An SPPayload to be nested into the data.
    @objc
    public func setData(withPayload data: Payload) {
        self.data = data.dictionary
    }

    /// Sets the data field of the self-describing JSON.
    /// NOTE: The data should be serializable to JSON using the JSONSerialization class in Foundation. An exception will be thrown if the data is not serializable. To make sure your data is serializable, you can use the `JSONSerialization.isValidJSONObject` function.
    /// - Parameter data: A self-describing JSON to be nested into the data.
    @objc
    public func setData(withSelfDescribingJson data: SelfDescribingJson) {
        self.data = data.dictionary
    }
    
    class func dictionary(schema: String, data: Any) -> [String: Any] {
        return [
            kSPSchema: schema,
            kSPData: data
        ]
    }
}
