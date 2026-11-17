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

/// Error returned when a Signals request can't be made or fails.
///
/// `status` is the HTTP status code of the response (e.g. 400 for an invalid identifier, 404 for an unknown
/// or non-public service), or 0 when no request was made (Signals isn't configured, user anonymisation is on,
/// no identifier is available) or no response was received (network error, timeout).
/// `message` holds the server's `error` message when it sent one.
@objc(SPSignalsError)
public class SignalsError: NSError {
    /// Error domain of all Signals errors.
    @objc
    public static let domain = "SPSignalsErrorDomain"

    /// HTTP status code of the response, or 0 when no request was made or no response was received.
    @objc
    public var status: Int { return code }

    /// Description of the error, the server's message when it sent one.
    @objc
    public var message: String { return localizedDescription }

    init(status: Int, message: String) {
        super.init(domain: SignalsError.domain, code: status, userInfo: [NSLocalizedDescriptionKey: message])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#if swift(>=5.5)
extension SignalsError: @unchecked Sendable {}
#endif
