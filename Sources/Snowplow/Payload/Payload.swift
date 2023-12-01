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

@objc(SPPayload)
public class Payload: NSObject {
    private var payload: [String : Any] = [:]
    @objc
    public var allowDiagnostic = true
    
    /// Returns the payload of that particular SPPayload object.
    /// - Returns: NSDictionary of data in the object.
    public var dictionary: [String : Any] {
        return payload
    }

    /// Returns the byte size of a payload.
    /// - Returns: A long representing the byte size of the payload.
    @objc
    public var byteSize: Int {
        if let data = try? JSONSerialization.data(withJSONObject: payload) {
            return data.count
        }
        return 0
    }

    @objc
    override public var description: String {
        return dictionary.description
    }

    ///  Initializes a newly allocated SPPayload
    ///  - Returns: A SnowplowPayload.
    @objc
    public override init() {
        super.init()
    }

    ///  Initializes a newly allocated SPPayload with an existing object of type NSDictionary.
    ///  - Parameter dictionary: An object of NSDictionary.
    ///  - Returns: A SnowplowPayload.
    @objc
    public init(dictionary: [String : Any]) {
        super.init()
        payload = dictionary
    }

    /// Adds a simple name-value pair into the SPPayload intance.
    /// - Parameters:
    /// - value: A NSString value
    /// - key: A key of type NSString
    @objc
    public func addValueToPayload(_ value: Any?, forKey key: String) {
        if value == nil {
            if payload[key] != nil {
                payload.removeValue(forKey: key)
            }
        } else {
            payload[key] = value
        }
    }

    ///  Adds a dictionary of attributes to be appended into the SPPayload instance. It does NOT overwrite the existing data in the object.
    ///  All attribute values must be String types to be added; all others are discarded.
    ///  - Parameter dictionary: An object of NSDictionary.
    @objc
    public func addDictionaryToPayload(_ dictionary: [String : Any]) {
        for (key, value) in dictionary {
            if value is String {
                addValueToPayload(value, forKey: key)
            }
        }
    }

    ///  Adds a dictionary of attributes to be appended into the SPPayload instance. Gives you the option to Base64 encode the data before adding it into the object.
    ///  - Parameters:
    ///  - json: NSData of JSON-compatible data to be added.
    ///  - encode: Boolean option to choose whether the JSON data should be encoded.
    ///  - typeEncoded: If the data is to be encoded, the result will be a value of the key in typeEncoded.
    ///  - typeNotEncoded: If the data is NOT going to be encoded, the result will be a value of the key in typeWhenNotEncoded.
    @objc
    public func addJsonToPayload(
        _ json: Data,
        base64Encoded encode: Bool,
        typeWhenEncoded typeEncoded: String?,
        typeWhenNotEncoded typeNotEncoded: String?
    ) {
        guard let _ = try? JSONSerialization.jsonObject(with: json) as? [String : Any] else { return }
        if encode {
            guard let typeEncoded = typeEncoded else { return }
            var encodedString = json.base64EncodedString(options: [])

            // We need URL safe with no padding. Since there is no built-in way to do this, we transform
            // the encoded payload to make it URL safe by replacing chars that are different in the URL-safe
            // alphabet. Namely, 62 is - instead of +, and 63 _ instead of /.
            // See: https://tools.ietf.org/html/rfc4648#section-5
            encodedString = encodedString.replacingOccurrences(of: "/", with: "_").replacingOccurrences(
                of: "+",
                with: "-")

            // There is also no padding since the length is implicitly known.
            encodedString = encodedString.trimmingCharacters(in: CharacterSet(charactersIn: "="))

            addValueToPayload(encodedString, forKey: typeEncoded)
        } else {
            guard let typeNotEncoded = typeNotEncoded else { return }
            addValueToPayload(String(data: json, encoding: .utf8), forKey: typeNotEncoded)
        }
    }

    ///  Adds a JSON string of attributes to be appended into the SPPayload instance. Gives you the option to Base64 encode the data before adding it into the object. This method converts the string to NSData and uses the data with addJsonStringToPayload:base64Encoded:typeWhenEncoded:typeWhenNotEncoded:
    ///  - Parameters:
    ///  - json: NSData of JSON-compatible data to be added.
    ///  - encode: Boolean option to choose whether the JSON data should be encoded.
    ///  - typeEncoded: If the data is to be encoded, the result will be a value of the key in typeEncoded.
    ///  - typeNotEncoded: If the data is NOT going to be encoded, the result will be a value of the key in typeWhenNotEncoded.
    @objc
    public func addJsonStringToPayload(
        _ json: String,
        base64Encoded encode: Bool,
        typeWhenEncoded typeEncoded: String?,
        typeWhenNotEncoded typeNotEncoded: String?
    ) {
        guard let data = json.data(using: .utf8) else { return }

        addJsonToPayload(
            data,
            base64Encoded: encode,
            typeWhenEncoded: typeEncoded,
            typeWhenNotEncoded: typeNotEncoded)

    }

    ///  Adds a dictionary of attributes to be appended into the SPPayload instance. Gives you the option to Base64 encode the data before adding it into the object. This method converts the dictionary to NSData and uses the data with addJsonStringToPayload:base64Encoded:typeWhenEncoded:typeWhenNotEncoded:
    ///  - Parameters:
    ///  - json: NSDictionary of JSON-compatible data to be added.
    ///  - encode: Boolean option to choose whether the JSON data should be encoded.
    ///  - typeEncoded: If the data is to be encoded, the result will be a value of the key in typeEncoded.
    ///  - typeNotEncoded: If the data is NOT going to be encoded, the result will be a value of the key in typeWhenNotEncoded.
    @objc
    public func addDictionaryToPayload(
        _ dictionary: [String : Any],
        base64Encoded encode: Bool,
        typeWhenEncoded typeEncoded: String?,
        typeWhenNotEncoded typeNotEncoded: String?
    ) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return }
        
        addJsonToPayload(
            data,
            base64Encoded: encode,
            typeWhenEncoded: typeEncoded,
            typeWhenNotEncoded: typeNotEncoded)
    }
    
    /// Shorthand to set and get payload values for keys.
    /// Setting a null value will remove the key from payload.
    @objc
    public subscript(key: String) -> Any? {
        get {
            dictionary[key]
        }
        set {
            addValueToPayload(newValue, forKey: key)
        }
    }
}
