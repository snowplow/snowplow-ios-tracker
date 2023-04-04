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
    /// - Parameter pageUrl: Page URL
    /// - Parameter pageTitle: Page title
    /// - Parameter referrer: Page referrer URL
    @objc
    public init(pageUrl: String) {
        self.pageUrl = pageUrl
    }
    
    override var eventName: String {
        return kSPEventPageView
    }
    
    override var payload: [String : Any] {
        var payload: [String : Any] = [
            kSPPageUrl: pageUrl
        ]
        payload[kSPPageTitle] = pageTitle
        payload[kSPPageRefr] = referrer
        return payload
    }
    
    // MARK: - Builders
    
    /// Page title.
    @objc
    public func pageTitle(_ title: String?) -> Self {
        self.pageTitle = title
        return self
    }
    
    /// Page referrer url.
    @objc
    public func referrer(_ referrer: String?) -> Self {
        self.referrer = referrer
        return self
    }
}
