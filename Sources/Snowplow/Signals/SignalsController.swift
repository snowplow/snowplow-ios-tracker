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

/// Controller for Snowplow Signals, available as `tracker.signals`.
///
/// Requires a `SignalsConfiguration` passed to `Snowplow.createTracker`; without it, calls fail with a `SignalsError`.
///
/// Read the attributes of a public service for the current app user:
///
/// ```swift
/// tracker.signals.getServiceAttributes(service: "app_profile") { attributes, error in
///     if let error = error {
///         print("Signals read failed (\(error.status)): \(error.message)")
///     } else if let attributes = attributes {
///         print(attributes["page_views_count"] ?? "no value")
///     }
/// }
///
/// // or, from an async context:
/// let attributes = try await tracker.signals.getServiceAttributes(service: "app_profile")
/// ```
@objc(SPSignalsController)
public protocol SignalsController {

    /// Reads the attributes of a public Signals service for one attribute key.
    ///
    /// Makes `GET {endpoint}/api/v1/services/{service}?{attributeKey}={identifier}` without credentials or caching.
    /// Only services whose access mode is public can be read without a token.
    ///
    /// The identifier defaults to the session context entity identifiers of this tracker:
    /// the session `userId` for `client_session_user_id` (the default attribute key),
    /// and the session `sessionId` for `client_session_session_id`.
    /// The session ID is created on the first tracked event, so track an event before reading by session.
    /// Any other attribute key needs an explicit identifier.
    ///
    /// The read is refused with status 0 when user anonymisation is enabled, since events then carry
    /// an anonymous user ID, and when the session is disabled or no session ID exists yet.
    ///
    /// - Parameters:
    ///   - service: Name of the public service to read.
    ///   - attributeKey: Attribute key the attributes are calculated for; defaults to `client_session_user_id`.
    ///   - identifier: Value of the attribute key; defaults to the session identifiers as described above.
    ///   - completion: Called on the main queue with the attributes by name (`NSNull` where there is no value yet),
    ///     or with a `SignalsError`.
    @objc
    func getServiceAttributes(
        service: String,
        attributeKey: String?,
        identifier: String?,
        completion: @escaping (_ attributes: [String: Any]?, _ error: SignalsError?) -> Void
    )
}

extension SignalsController {

    /// Reads the attributes of a public Signals service for the session user (`client_session_user_id`).
    /// See `getServiceAttributes(service:attributeKey:identifier:completion:)`.
    public func getServiceAttributes(
        service: String,
        completion: @escaping (_ attributes: [String: Any]?, _ error: SignalsError?) -> Void
    ) {
        getServiceAttributes(service: service, attributeKey: nil, identifier: nil, completion: completion)
    }

#if swift(>=5.5)
    /// Reads the attributes of a public Signals service for one attribute key.
    /// See `getServiceAttributes(service:attributeKey:identifier:completion:)`.
    /// - Returns: The attributes by name (`NSNull` where there is no value yet).
    /// - Throws: `SignalsError` when the read is refused or fails.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func getServiceAttributes(
        service: String,
        attributeKey: String? = nil,
        identifier: String? = nil
    ) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            getServiceAttributes(service: service, attributeKey: attributeKey, identifier: identifier) { attributes, error in
                if let attributes = attributes {
                    continuation.resume(returning: attributes)
                } else {
                    continuation.resume(throwing: error ?? SignalsError(status: 0, message: "Signals read returned no attributes"))
                }
            }
        }
    }
#endif
}
