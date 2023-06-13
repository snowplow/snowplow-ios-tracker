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

class GDPRControllerImpl: Controller, GDPRController {
    var gdpr: GDPRContext?
    
    // MARK: - Methods

    func reset(
        basis basisForProcessing: GDPRProcessingBasis,
        documentId: String?,
        documentVersion: String?,
        documentDescription: String?
    ) {
        gdpr = GDPRContext(
            basis: basisForProcessing,
            documentId: documentId,
            documentVersion: documentVersion,
            documentDescription: documentDescription)
        tracker.gdprContext = gdpr
        dirtyConfig.gdpr = gdpr
    }

    func disable() {
        dirtyConfig.isEnabled = false
        tracker.gdprContext = nil
    }

    var isEnabled: Bool {
        get {
            return tracker.gdprContext != nil
        }
    }

    func enable() -> Bool {
        if let gdpr = gdpr { tracker.gdprContext = gdpr }
        else { return false }
        dirtyConfig.isEnabled = true
        return true
    }

    var basisForProcessing: GDPRProcessingBasis {
        get {
            return ((gdpr)?.basis)!
        }
    }

    var documentId: String? {
        get {
            return (gdpr)?.documentId
        }
    }

    var documentVersion: String? {
        get {
            return (gdpr)?.documentVersion
        }
    }

    var documentDescription: String? {
        get {
            return (gdpr)?.documentDescription
        }
    }

    // MARK: - Private methods

    private var tracker: Tracker {
        get {
            return serviceProvider.tracker
        }
    }

    private var dirtyConfig: GDPRConfiguration {
        get {
            return serviceProvider.gdprConfiguration
        }
    }
}
