//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

/// Allows the tracking of JavaScript events from WebViews.
class WebViewReader: Event {
    let selfDescribingEventData: SelfDescribingJson?
    let eventName: String?
    let trackerVersion: String?
    let useragent: String?
    let pageUrl: String?
    let pageTitle: String?
    let referrer: String?
    let category: String?
    let action: String?
    let label: String?
    let property: String?
    let value: Double?
    let pingXOffsetMin: Int?
    let pingXOffsetMax: Int?
    let pingYOffsetMin: Int?
    let pingYOffsetMax: Int?
    
    init(
        selfDescribingEventData: SelfDescribingJson? = nil,
        eventName: String? = nil,
        trackerVersion: String? = nil,
        useragent: String? = nil,
        pageUrl: String? = nil,
        pageTitle: String? = nil,
        referrer: String? = nil,
        category: String? = nil,
        action: String? = nil,
        label: String? = nil,
        property: String? = nil,
        value: Double? = nil,
        pingXOffsetMin: Int? = nil,
        pingXOffsetMax: Int? = nil,
        pingYOffsetMin: Int? = nil,
        pingYOffsetMax: Int? = nil
    ) {
        self.selfDescribingEventData = selfDescribingEventData
        self.eventName = eventName
        self.trackerVersion = trackerVersion
        self.useragent = useragent
        self.pageUrl = pageUrl
        self.pageTitle = pageTitle
        self.referrer = referrer
        self.category = category
        self.action = action
        self.label = label
        self.property = property
        self.value = value
        self.pingXOffsetMin = pingXOffsetMin
        self.pingXOffsetMax = pingXOffsetMax
        self.pingYOffsetMin = pingYOffsetMin
        self.pingYOffsetMax = pingYOffsetMax
        
        super.init()
    }

    override var payload: [String : Any] {
        var payload: [String: Any] = [:]
                
        if let selfDescribingEventData = selfDescribingEventData {
            payload[kSPWebViewEventData] = selfDescribingEventData
        }
        if let eventName = eventName {
            payload[kSPEvent] = eventName
        }
        if let trackerVersion = trackerVersion {
            payload[kSPTrackerVersion] = trackerVersion
        }
        if let useragent = useragent {
            payload[kSPUseragent] = useragent
        }
        if let pageUrl = pageUrl {
            payload[kSPPageUrl] = pageUrl
        }
        if let pageTitle = pageTitle {
            payload[kSPPageTitle] = pageTitle
        }
        if let referrer = referrer {
            payload[kSPPageRefr] = referrer
        }
        if let category = category {
            payload[kSPStructCategory] = category
        }
        if let action = action {
            payload[kSPStructAction] = action
        }
        if let label = label {
            payload[kSPStructLabel] = label
        }
        if let property = property {
            payload[kSPStructProperty] = property
        }
        if let value = value {
            payload[kSPStructValue] = value
        }
        if let pingXOffsetMin = pingXOffsetMin {
            payload[kSPPingXOffsetMin] = pingXOffsetMin
        }
        if let pingXOffsetMax = pingXOffsetMax {
            payload[kSPPingXOffsetMax] = pingXOffsetMax
        }
        if let pingYOffsetMin = pingYOffsetMin {
            payload[kSPPingYOffsetMin] = pingYOffsetMin
        }
        if let pingYOffsetMax = pingYOffsetMax {
            payload[kSPPingYOffsetMax] = pingYOffsetMax
        }
        return payload
    }
}
