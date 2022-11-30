//  SPGDPRConfiguration.swift
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

import Foundation

@objc(SPGDPRConfigurationProtocol)
public protocol GDPRConfigurationProtocol: AnyObject {
    /// Basis for processing.
    @objc
    var basisForProcessing: GDPRProcessingBasis { get }
    /// ID of a GDPR basis document.
    @objc
    var documentId: String? { get }
    /// Version of the document.
    @objc
    var documentVersion: String? { get }
    /// Description of the document.
    @objc
    var documentDescription: String? { get }
}

/// This class allows the GDPR configuration of the tracker.
@objc(SPGDPRConfiguration)
public class GDPRConfiguration: Configuration, GDPRConfigurationProtocol {
    /// Basis for processing.
    @objc
    public var basisForProcessing: GDPRProcessingBasis
    /// ID of a GDPR basis document.
    @objc
    public var documentId: String?
    /// Version of the document.
    @objc
    public var documentVersion: String?
    /// Description of the document.
    @objc
    public var documentDescription: String?

    /// Enables GDPR context to be sent with each event.
    /// - Parameters:
    ///   - basisForProcessing: GDPR Basis for processing.
    ///   - documentId: ID of a GDPR basis document.
    ///   - documentVersion: Version of the document.
    ///   - documentDescription: Description of the document.
    @objc
    public init(
        basis basisForProcessing: GDPRProcessingBasis,
        documentId: String?,
        documentVersion: String?,
        documentDescription: String?
    ) {
        self.basisForProcessing = basisForProcessing
        self.documentId = documentId ?? ""
        self.documentVersion = documentVersion ?? ""
        self.documentDescription = documentDescription ?? ""
        super.init()
    }

    // MARK: - NSCopying

    @objc
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = GDPRConfiguration(basis: basisForProcessing,
                                     documentId: documentId,
                                     documentVersion: documentVersion,
                                     documentDescription: documentDescription)
        return copy
    }

    // MARK: - NSSecureCodin
    
    @objc
    public override class var supportsSecureCoding: Bool { return true }

    @objc
    public override func encode(with coder: NSCoder) {
        coder.encode(basisForProcessing.rawValue, forKey: "basisForProcessing")
        coder.encode(documentId, forKey: "documentId")
        coder.encode(documentVersion, forKey: "documentVersion")
        coder.encode(documentDescription, forKey: "documentDescription")
    }

    required init?(coder: NSCoder) {
        if let basisForProcessing = GDPRProcessingBasis(rawValue: coder.decodeInteger(forKey: "basisForProcessing")) {
            self.basisForProcessing = basisForProcessing
            self.documentId = coder.decodeObject(forKey: "documentId") as? String ?? ""
            self.documentVersion = coder.decodeObject(forKey: "documentVersion") as? String ?? ""
            self.documentDescription = coder.decodeObject(forKey: "documentDescription") as? String ?? ""
            super.init()
        } else {
            return nil
        }
    }
}
