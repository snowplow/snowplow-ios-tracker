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

/** Media player event fired when the user activated a skip control to skip the ad creative. */
@objc(SPMediaAdSkipEvent)
public class MediaAdSkipEvent: SelfDescribingAbstract {
    
    /// The percent of the way through the ad.
    public var percentProgress: Int?
    
    override var schema: String {
        return MediaSchemata.eventSchema("ad_skip")
    }
    
    override var payload: [String : Any] {
        var data: [String: Any] = [:]
        if let percentProgress = percentProgress { data["percentProgress"] = percentProgress }
        return data
    }
    
    /// - Parameter percentProgress: The percent of the way through the ad.
    public init(percentProgress: Int? = nil) {
        self.percentProgress = percentProgress
    }
    
    @objc
    public override init() {
    }
    
    /// The percent of the way through the ad.
    @objc
    public func percentProgress(_ percentProgress: Int) -> Self {
        self.percentProgress = percentProgress
        return self
    }
}
