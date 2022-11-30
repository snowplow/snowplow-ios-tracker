//
//  PageView.swift
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

/// A pageview event.
/// @deprecated This event has been designed for web trackers, not suitable for mobile apps. Use DeepLinkReceived event to track deep link received in the app.
@objc(SPPageView)
public class PageView : PrimitiveAbstract {
    /// Page url.
    @objc
    public var pageUrl: String
    /// Page title.
    @objc
    public var pageTitle: String?
    /// Page referrer url.
    @objc
    public var referrer: String?

    /// Creates a Page View event
    /// @param pageUrl Page URL
    /// @param pageTitle Page title
    /// @param referrer Page referrer URL
    @objc
    public init(pageUrl: String) {
        self.pageUrl = pageUrl
    }
    
    @objc
    override public var eventName: String {
        return kSPEventPageView
    }
    
    override public var payload: [String : NSObject] {
        var payload: [String: NSObject] = [
            kSPPageUrl: pageUrl as NSObject
        ]
        payload[kSPPageTitle] = pageTitle as NSObject?
        payload[kSPPageRefr] = referrer as NSObject?
        return payload
    }
}
