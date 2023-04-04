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

@objc(SPGDPRController)
public protocol GDPRController: GDPRConfigurationProtocol {
    /// Whether the recorded GDPR context is enabled and will be attached as context.
    @objc
    var isEnabled: Bool { get }
    /// Reset GDPR context to be sent with each event.
    /// - Parameters:
    ///   - basisForProcessing: GDPR Basis for processing.
    ///   - documentId: ID of a GDPR basis document.
    ///   - documentVersion: Version of the document.
    ///   - documentDescription: Description of the document.
    @objc
    func reset(
            basis basisForProcessing: GDPRProcessingBasis,
            documentId: String?,
            documentVersion: String?,
            documentDescription: String?
        )
    /// Enable the GDPR context recorded.
    @objc
    func enable() -> Bool
    /// Disable the GDPR context recorded.
    @objc
    func disable()
}
