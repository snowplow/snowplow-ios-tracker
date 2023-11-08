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

class EmitterControllerIQWrapper: EmitterController {
    
    private let controller: EmitterController
    
    init(controller: EmitterController) {
        self.controller = controller
    }

    // MARK: - Properties

    var bufferOption: BufferOption {
        get { return InternalQueue.sync { controller.bufferOption } }
        set { InternalQueue.sync { controller.bufferOption = newValue } }
    }

    var byteLimitGet: Int {
        get { return InternalQueue.sync { controller.byteLimitGet } }
        set { InternalQueue.sync { controller.byteLimitGet = newValue } }
    }

    var byteLimitPost: Int {
        get { return InternalQueue.sync { controller.byteLimitPost } }
        set { InternalQueue.sync { controller.byteLimitPost = newValue } }
    }

    var serverAnonymisation: Bool {
        get { return InternalQueue.sync { controller.serverAnonymisation } }
        set { InternalQueue.sync { controller.serverAnonymisation = newValue } }
    }

    var emitRange: Int {
        get { return InternalQueue.sync { controller.emitRange } }
        set { InternalQueue.sync { controller.emitRange = newValue } }
    }

    var threadPoolSize: Int {
        get { return InternalQueue.sync { controller.threadPoolSize } }
        set { InternalQueue.sync { controller.threadPoolSize = newValue } }
    }

    var requestCallback: RequestCallback? {
        get { return InternalQueue.sync { controller.requestCallback } }
        set { InternalQueue.sync { controller.requestCallback = newValue } }
    }

    var dbCount: Int {
        return InternalQueue.sync { controller.dbCount }
    }

    var isSending: Bool {
        return InternalQueue.sync { controller.isSending }
    }
    
    var customRetryForStatusCodes: [Int : Bool]? {
        get { return InternalQueue.sync { controller.customRetryForStatusCodes } }
        set { InternalQueue.sync { controller.customRetryForStatusCodes = newValue } }
    }
    
    var retryFailedRequests: Bool {
        get { return InternalQueue.sync { controller.retryFailedRequests } }
        set { InternalQueue.sync { controller.retryFailedRequests = newValue } }
    }

    // MARK: - Methods

    func flush() {
        InternalQueue.sync { controller.flush() }
    }

    func pause() {
        InternalQueue.sync { controller.pause() }
    }

    func resume() {
        InternalQueue.sync { controller.resume() }
    }

}
