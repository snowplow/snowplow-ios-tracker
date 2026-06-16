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

/// Errors that can occur during payload processing and serialization.
///
/// `PayloadError` represents various error conditions that may arise when working with
/// payload data, particularly during JSON serialization and data conversion operations.
public enum PayloadError: Error {
    /// Indicates that JSON serialization to a dictionary failed.
    ///
    /// This error occurs when JSON data cannot be converted to a `[String: Any]` dictionary,
    /// typically when the JSON structure is not a valid object (e.g., it's an array or primitive value)
    /// or when the serialization process encounters incompatible data types.
    ///
    /// This error is commonly thrown by convenience initializers that accept `Encodable` data
    /// when the encoded JSON cannot be represented as a dictionary structure required by
    /// Snowplow's payload format.
    case jsonSerializationToDictionaryFailed
}
