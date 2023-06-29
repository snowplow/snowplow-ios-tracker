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
public class GDPRConfiguration: NSObject, GDPRConfigurationProtocol, ConfigurationProtocol {
    private var _basisForProcessing: GDPRProcessingBasis?
    /// Basis for processing.
    @objc
    public var basisForProcessing: GDPRProcessingBasis {
        get { return _basisForProcessing ?? sourceConfig?.basisForProcessing ?? .contract }
        set { _basisForProcessing = newValue }
    }
    
    private var _documentId: String?
    /// ID of a GDPR basis document.
    @objc
    public var documentId: String? {
        get { return _documentId ?? sourceConfig?.documentId }
        set { _documentId = newValue }
    }
    
    private var _documentVersion: String?
    /// Version of the document.
    @objc
    public var documentVersion: String? {
        get { return _documentVersion ?? sourceConfig?.documentVersion }
        set { _documentVersion = newValue }
    }
    
    private var _documentDescription: String?
    /// Description of the document.
    @objc
    public var documentDescription: String? {
        get { return _documentDescription ?? sourceConfig?.documentDescription }
        set { _documentDescription = newValue }
    }
    
    internal override init() {
    }

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
        self._basisForProcessing = basisForProcessing
        self._documentId = documentId
        self._documentVersion = documentVersion
        self._documentDescription = documentDescription
        super.init()
    }
    
    // MARK: - Internal
    
    /// Fallback configuration to read from in case requested values are not present in this configuraiton.
    internal var sourceConfig: GDPRConfiguration?
    
    private var _gdpr: GDPRContext?
    internal var gdpr: GDPRContext? {
        get { return _gdpr ?? sourceConfig?.gdpr }
        set { _gdpr = newValue }
    }
    
    private var _isEnabled: Bool?
    internal var isEnabled : Bool {
        get { return _isEnabled ?? sourceConfig?.isEnabled ?? false }
        set { _isEnabled = newValue }
    }
    
    // MARK: - Builders
    
    /// Basis for processing.
    @objc
    public func basisForProcessing(_ basis: GDPRProcessingBasis) -> Self {
        self.basisForProcessing = basis
        return self
    }
    
    /// ID of a GDPR basis document.
    @objc
    public func documentId(_ documentId: String?) -> Self {
        self.documentId = documentId
        return self
    }
    
    /// Version of the document.
    @objc
    public func documentVersion(_ version: String?) -> Self {
        self.documentVersion = version
        return self
    }
    
    /// Description of the document.
    @objc
    public func documentDescription(_ description: String?) -> Self {
        self.documentDescription = description
        return self
    }
}
