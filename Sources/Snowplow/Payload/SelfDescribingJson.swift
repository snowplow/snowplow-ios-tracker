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

/// @class SPSelfDescribingJson
/// The class that represents self-describing JSONs.
/// This class holds the information of a self-describing JSON.
/// - seealso: SPPayload
@objc(SPSelfDescribingJson)
public class SelfDescribingJson: NSObject {
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
    /// - Parameters:
    ///   - schema: A valid schema string.
    ///   - data: Dictionary to set for data field of the self-describing JSON.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public convenience init(schema: String, andDictionary data: [String : Any]) {
        self.init(schema: schema, andData: data)
    }

    /// Initializes a newly allocated SPSelfDescribingJson.
    /// - Parameters:
    ///   - schema: A valid schema string.
    ///   - data: Payload to set for data field of the self-describing JSON.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public convenience init(schema: String, andPayload payload: Payload) {
        self.init(schema: schema, andData: payload.dictionary)
    }

    /// Initializes a newly allocated SPSelfDescribingJson.
    /// - Parameters:
    ///   - schema: A valid schema URI.
    ///   - data: Self-describing JSON to set for data field of the self-describing JSON.
    /// - Returns: An SPSelfDescribingJson.
    @objc
    public convenience init(schema: String, andSelfDescribingJson data: SelfDescribingJson) {
        self.init(schema: schema, andData: data.dictionary)
    }

    /// Sets the data field of the self-describing JSON.
    /// - Parameter data: An SPPayload to be nested into the data.
    @objc
    public func setData(withPayload data: Payload) {
        self.data = data.dictionary
    }

    /// Sets the data field of the self-describing JSON.
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
