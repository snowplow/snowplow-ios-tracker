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

@objc(SPRequest)
public class Request: NSObject {
    @objc
    public private(set) var payload: Payload?
    @objc
    public private(set) var emitterEventIds: [Int64]
    @objc
    public private(set) var oversize = false
    @objc
    public private(set) var customUserAgent: String?

    convenience init(payload: Payload, emitterEventId: Int64) {
        self.init(payload: payload, emitterEventId: emitterEventId, oversize: false)
    }

    init(payload: Payload, emitterEventId: Int64, oversize: Bool) {
        emitterEventIds = [emitterEventId]
        super.init()
        self.payload = payload
        customUserAgent = userAgent(from: payload)
        self.oversize = oversize
    }

    init(payloads: [Payload], emitterEventIds: [Int64]) {
        self.emitterEventIds = emitterEventIds
        super.init()
        var tempUserAgent: String? = nil
        var payloadData: [[String : Any]] = []
        for payload in payloads {
            payloadData.append(payload.dictionary)
            tempUserAgent = userAgent(from: payload)
        }
        let payloadBundle = SelfDescribingJson.dictionary(schema: kSPPayloadDataSchema,
                                                          data: payloadData)
        payload = Payload(dictionary: payloadBundle)
        customUserAgent = tempUserAgent
        oversize = false
    }

    func userAgent(from payload: Payload) -> String? {
        return (payload.dictionary[kSPUseragent] as? String)
    }
}
