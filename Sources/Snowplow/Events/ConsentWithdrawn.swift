//
//  ConsentWithdrawn.swift
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

    override var payload: [String : NSObject] {
        return [
            KSPCwAll: all ? NSNumber(value: true) : NSNumber(value: false)
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
        contexts.append(contentsOf: allDocuments)
    }
}
