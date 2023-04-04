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

/// A consent withdrawn event.
///
/// Schema: `iglu:com.snowplowanalytics.snowplow/consent_withdrawn/jsonschema/1-0-0`
@objc(SPConsentWithdrawn)
public class ConsentWithdrawn: SelfDescribingAbstract {
    /// Consent to all.
    @objc
    public var all = false
    /// Identifier of the first document.
    @objc
    public var documentId: String?
    /// Version of the first document.
    @objc
    public var version: String?
    /// Name of the first document.
    @objc
    public var name: String?
    /// Description of the first document.
    @objc
    public var documentDescription: String?
    /// Other documents.
    ///
    /// Schema for the documents: `iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0`
    @objc
    public var documents: [SelfDescribingJson]?

    override var schema: String {
        return kSPConsentWithdrawnSchema
    }

    override var payload: [String : Any] {
        return [
            KSPCwAll: all
        ]
    }

    @objc
    var allDocuments: [SelfDescribingJson] {
        var results: [SelfDescribingJson] = []
        guard let documentId = documentId, let version = version else { return results }

        let document = ConsentDocument(documentId: documentId, version: version)
        if let name = name {
            document.name = name
        }
        if let documentDescription = documentDescription {
            document.documentDescription = documentDescription
        }

        results.append(document.payload)
        if let documents = documents {
            results.append(contentsOf: documents)
        }
        return results
    }

    override func beginProcessing(withTracker tracker: Tracker) {
        entities.append(contentsOf: allDocuments)
    }
    
    // MARK: - Builders
    
    /// Consent to all.
    @objc
    public func all(_ all: Bool) -> Self {
        self.all = all
        return self
    }
    
    /// Identifier of the first document.
    @objc
    public func documentId(_ documentId: String?) -> Self {
        self.documentId = documentId
        return self
    }
    
    /// Version of the first document.
    @objc
    public func version(_ version: String?) -> Self {
        self.version = version
        return self
    }
    
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
    
    /// Other documents.
    ///
    /// Schema for the documents: `iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0`
    @objc
    public func documents(_ documents: [SelfDescribingJson]?) -> Self {
        self.documents = documents
        return self
    }
}
