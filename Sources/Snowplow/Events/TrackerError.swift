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

let kMaxMessageLength = 2048
let kMaxStackLength = 8192
let kMaxExceptionNameLength = 1024

import Foundation

/// Tracker error event used in diagnostic autotracking.
///
/// Schema: `iglu:com.snowplowanalytics.snowplow/diagnostic_error/jsonschema/1-0-0`
@objc(SPTrackerError)
public class TrackerError : SelfDescribingAbstract {
    /// Class name or source where the error appeared.
    @objc
    public var source: String
    /// Message of the error.
    @objc
    public var message: String
    /// Error involved in the error.
    @objc
    public var error: Error?
    /// Exception involved in the error.
    @objc
    public var exception: NSException?
    
    /// Create tracker error.
    /// - Parameter source: Class name or source where the error appeared.
    /// - Parameter message: Message of the error.
    /// - Parameter error: Error involved in the error.
    /// - Parameter exception: Exception involved in the error.
    @objc
    public init(source: String, message: String, error: Error? = nil, exception: NSException? = nil) {
        self.source = source
        self.message = message
        self.error = error
        self.exception = exception
    }
    
    override var schema: String {
        return kSPDiagnosticErrorSchema
    }
    
    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        payload[kSPDiagnosticErrorClassName] = source
        payload[kSPDiagnosticErrorMessage] = truncate(message, maxLength: kMaxMessageLength)
        if let error = error {
            payload[kSPDiagnosticErrorExceptionName] = error
        }
        if let exception = exception {
            payload[kSPDiagnosticErrorExceptionName] = truncate(exception.name.rawValue, maxLength: kMaxExceptionNameLength)
            let symbols = (exception).callStackSymbols
            if symbols.count != 0 {
                let stackTrace = "Stacktrace:\n\(symbols)"
                payload[kSPDiagnosticErrorStack] = truncate(stackTrace, maxLength: kMaxStackLength)
            }
        }
        return payload
    }

    // -- Private methods

    private func truncate(_ s: String, maxLength: Int) -> String {
        return String(s.prefix(maxLength))
    }
}
