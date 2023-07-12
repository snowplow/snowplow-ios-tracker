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

/// A consent document event.
///
/// Schema: `iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0`
@objc(SPConsentDocument)
public class ConsentDocument: NSObject {
    /// Identifier of the document.
    @objc
    public var documentId: String
    /// Version of the document.
    @objc
    public var version: String
    /// Name of the document.
    @objc
    public var name: String?
    /// Description of the document.
    @objc
    public var documentDescription: String?

    /// Create a consent document event.
    /// - Parameters:
    ///   - documentId: identifier of the document.
    ///   - version: version of the document.
    @objc
    public init(documentId: String, version: String) {
        self.documentId = documentId
        self.version = version
    }

    /// Returns the payload.
    @objc
    public var payload: SelfDescribingJson {
        var event: [String : String] = [:]
        event[kSPCdId] = documentId
        event[kSPCdVersion] = version
        if (name?.count ?? 0) != 0 {
            event[kSPCdName] = name ?? ""
        }
        if (documentDescription?.count ?? 0) != 0 {
            event[KSPCdDescription] = documentDescription ?? ""
        }
        return SelfDescribingJson(
            schema: kSPConsentDocumentSchema,
            andDictionary: event)
    }
    
    // MARK: - Builders
    
    /// Name of the document.
    @objc
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
    
    /// Description of the document.
    @objc
    public func documentDescription(_ description: String?) -> Self {
        self.documentDescription = description
        return self
    }
}
