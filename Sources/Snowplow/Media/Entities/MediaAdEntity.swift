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

/**
 Properties for the ad context entity attached to media events during ad playback.
 Entity schema: `iglu:com.snowplowanalytics.snowplow.media/ad/jsonschema/1-0-0`
 */
@objc(SPMediaAd)
public class MediaAdEntity: NSObject {
    /// Friendly name of the ad
    public var name: String?
    /// Unique identifier for the ad
    public var adId: String
    /// The ID of the ad creative
    public var creativeId: String?
    /// The position of the ad within the ad break, starting with 1
    /// It is automatically assigned by the tracker based on the tracked ad break start and ad start events.
    public var podPosition: Int?
    /// Length of the video ad in seconds
    public var duration: Double?
    /// Indicating whether skip controls are made available to the end user
    public var skippable: Bool?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "adId": adId
        ]
        if let name = name { data["name"] = name }
        if let creativeId = creativeId { data["creativeId"] = creativeId }
        if let podPosition = podPosition { data["podPosition"] = podPosition }
        if let duration = duration { data["duration"] = duration }
        if let skippable = skippable { data["skippable"] = skippable }
        
        return SelfDescribingJson(schema: MediaSchemata.adSchema, andData: data)
    }
    
    /// - Parameter adId: Unique identifier for the ad
    @objc
    public init(adId: String) {
        self.adId = adId
    }
    
    /// - Parameter name: Friendly name of the ad
    /// - Parameter adId: Unique identifier for the ad
    /// - Parameter creativeId: The ID of the ad creative
    /// - Parameter duration: Length of the video ad in seconds
    /// - Parameter skippable: Indicating whether skip controls are made available to the end user
    public init(
                adId: String,
                name: String? = nil,
                creativeId: String? = nil,
                duration: Double? = nil,
                skippable: Bool? = nil) {
        self.name = name
        self.adId = adId
        self.creativeId = creativeId
        self.duration = duration
        self.skippable = skippable
    }
    
    /// Friendly name of the ad
    @objc
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
    
    /// Unique identifier for the ad
    @objc
    public func adId(_ adId: String) -> Self {
        self.adId = adId
        return self
    }
    
    /// The ID of the ad creative
    @objc
    public func creativeId(_ creativeId: String?) -> Self {
        self.creativeId = creativeId
        return self
    }
    
    /// The position of the ad within the ad break, starting with 1
    /// It is automatically assigned by the tracker based on the tracked ad break start and ad start events.
    @objc
    public func podPosition(_ podPosition: Int) -> Self {
        self.podPosition = podPosition
        return self
    }
    
    /// Length of the video ad in seconds
    @objc
    public func duration(_ duration: Double) -> Self {
        self.duration = duration
        return self
    }
    
    /// Indicating whether skip controls are made available to the end user
    @objc
    public func skippable(_ skippable: Bool) -> Self {
        self.skippable = skippable
        return self
    }
    
    func update(from ad: MediaAdEntity) {
        self.adId = ad.adId
        if let name = ad.name { self.name = name }
        if let creativeId = ad.creativeId { self.creativeId = creativeId }
        if let duration = ad.duration { self.duration = duration }
        if let skippable = ad.skippable { self.skippable = skippable }
    }
}
