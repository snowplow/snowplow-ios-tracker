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

/// A consent granted event.
///
/// Schema: `iglu:com.snowplowanalytics.snowplow/consent_granted/jsonschema/1-0-0`
@objc(SPConsentGranted)
public class ConsentGranted: SelfDescribingAbstract {
    /// Expiration of the consent.
    @objc
    public var expiry: String
    /// Identifier of the first document.
    @objc
    public var documentId: String
    /// Version of the first document.
    @objc
    public var version: String
    /// Name of the first document.
    @objc
    public var name: String?
    /// Description of the first document.
    @objc
    public var documentDescription: String?
    /// Other attached documents.
    ///
    /// Schema for the documents: `iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0`
    @objc
    public var documents: [SelfDescribingJson]?

    /// Creates a consent granted event with a first document.
    /// - Parameters:
    ///   - expiry: consent expiration.
    ///   - documentId: identifier of the first document.
    ///   - version: version of the first document.
    @objc
    public init(expiry: String, documentId: String, version: String) {
        self.expiry = expiry
        self.documentId = documentId
        self.version = version
    }

    /// Retuns the full list of attached documents.
    @objc
    public var allDocuments: [SelfDescribingJson] {
        var results: [SelfDescribingJson] = []

        let document = ConsentDocument(documentId: documentId, version: version)
        if (name?.count ?? 0) != 0 {
            document.name = name
        }
        if documentDescription != nil {
            document.documentDescription = documentDescription
        }

        results.append(document.payload)
        if let documents = documents {
            results.append(contentsOf: documents)
        }
        return results
    }

    override var schema: String {
        return kSPConsentGrantedSchema
    }

    override var payload: [String : Any] {
        return [
            KSPCgExpiry: expiry
        ]
    }

    override func beginProcessing(withTracker tracker: Tracker) {
        entities.append(contentsOf: allDocuments) // TODO: Only the user should modify the public contexts property
    }
    
    // MARK: - Builders
    
    /// Name of the first document.
    @objc
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
    
    /// Description of the first document.
    @objc
    public func documentDescription(_ description: String?) -> Self {
        self.documentDescription = description
        return self
    }
    
    /// Other attached documents.
    ///
    /// Schema for the documents: `iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0`
    @objc
    public func documents(_ documents: [SelfDescribingJson]?) -> Self {
        self.documents = documents
        return self
    }
}
