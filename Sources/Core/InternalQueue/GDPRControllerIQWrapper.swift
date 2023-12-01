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

class GDPRControllerIQWrapper: GDPRController {
    
    private let controller: GDPRController
    
    init(controller: GDPRController) {
        self.controller = controller
    }
    
    // MARK: - Methods

    func reset(basis: GDPRProcessingBasis, documentId: String?, documentVersion: String?, documentDescription: String?) {
        InternalQueue.sync {
            controller.reset(basis: basis, documentId: documentId, documentVersion: documentVersion, documentDescription: documentDescription)
        }
    }

    func disable() {
        InternalQueue.sync { controller.disable() }
    }

    var isEnabled: Bool {
        return InternalQueue.sync { controller.isEnabled }
    }

    func enable() -> Bool {
        InternalQueue.sync { controller.enable() }
    }

    var basisForProcessing: GDPRProcessingBasis {
        InternalQueue.sync { controller.basisForProcessing }
    }

    var documentId: String? {
        InternalQueue.sync { controller.documentId }
    }

    var documentVersion: String? {
        InternalQueue.sync { controller.documentVersion }
    }

    var documentDescription: String? {
        InternalQueue.sync { controller.documentDescription }
    }

}
