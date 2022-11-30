//
//  TrackerError.swift
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

let kMaxMessageLength = 2048
let kMaxStackLength = 8192
let kMaxExceptionNameLength = 1024

import Foundation

@objc(SPTrackerError)
public class TrackerError : SelfDescribingAbstract {
    @objc
    public var source: String
    @objc
    public var message: String
    @objc
    public var error: Error?
    @objc
    public var exception: NSException?
    
    @objc
    public init(source: String, message: String, error: Error? = nil, exception: NSException? = nil) {
        self.source = source
        self.message = message
        self.error = error
        self.exception = exception
    }
    
    override public var schema: String {
        return kSPDiagnosticErrorSchema
    }
    
    override public var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPDiagnosticErrorClassName] = source as NSObject
        payload[kSPDiagnosticErrorMessage] = truncate(message, maxLength: kMaxMessageLength) as NSObject
        if let error = error {
            payload[kSPDiagnosticErrorExceptionName] = error as NSObject
        }
        if let exception = exception {
            payload[kSPDiagnosticErrorExceptionName] = truncate(exception.name.rawValue, maxLength: kMaxExceptionNameLength) as NSObject
            let symbols = (exception).callStackSymbols
            if symbols.count != 0 {
                let stackTrace = "Stacktrace:\n\(symbols)"
                payload[kSPDiagnosticErrorStack] = truncate(stackTrace, maxLength: kMaxStackLength) as NSObject
            }
        }
        return payload
    }

    // -- Private methods

    private func truncate(_ s: String, maxLength: Int) -> String {
        return String(s.prefix(maxLength))
    }
}
