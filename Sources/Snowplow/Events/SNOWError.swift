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

/// Error event tracked by exception autotracking.
///
/// Schema: `iglu:com.snowplowanalytics.snowplow/application_error/jsonschema/1-0-2`
@objc(SPSNOWError)
public class SNOWError: SelfDescribingAbstract {
    /// Error message
    @objc
    public var message: String
    /// Error name
    @objc
    public var name: String?
    /// Stacktrace for the error
    @objc
    public var stackTrace: String?
    
    /// Creates a SNOWError event.
    /// - Parameter message: Error message
    @objc
    public init(message: String) {
        self.message = message
    }
    
    override var schema: String {
        return kSPErrorSchema
    }

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        payload[kSPErrorMessage] = message
        payload[kSPErrorStackTrace] = stackTrace
        payload[kSPErrorName] = name
        payload[kSPErrorLanguage] = "SWIFT"
        return payload
    }
    
    // MARK: - Builders
    
    /// Error name
    @objc
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
    
    /// Stacktrace for the error
    @objc
    public func stackTrace(_ stackTrace: String?) -> Self {
        self.stackTrace = stackTrace
        return self
    }
}
