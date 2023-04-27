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

class MediaAdTracking {
    var ad: MediaAdUpdate?
    var adBreak: MediaAdBreakUpdate?
    private var podPosition = 0
    
    var entities: [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let entity = self.adBreak?.entity { entities.append(entity) }
        if let entity = self.ad?.entity { entities.append(entity) }
        return entities
    }
    
    func updateForThisEvent(eventType: MediaEventType,
                            mediaPlayer: MediaUpdate,
                            ad: MediaAdUpdate?,
                            adBreak: MediaAdBreakUpdate?) {
        switch (eventType) {
        case .adStart:
            self.ad = nil
            self.podPosition += 1
        case .adBreakStart:
            self.adBreak = nil
            self.podPosition = 0
        default: break
        }
        
        if let ad = ad {
            self.ad?.update(from: ad)
            self.ad = self.ad ?? ad
            if podPosition > 0 { self.ad?.podPosition = podPosition }
        }
        
        if let adBreak = adBreak {
            self.adBreak?.update(adBreak: adBreak)
            self.adBreak = self.adBreak ?? adBreak
            self.adBreak?.update(mediaPlayer: mediaPlayer)
        }
        
        switch (eventType) {
        case .adStart: self.ad?.percentProgress = 0
        case .adFirstQuartile: self.ad?.percentProgress = 25
        case .adMidpoint: self.ad?.percentProgress = 50
        case .adThirdQuartile: self.ad?.percentProgress = 75
        case .adComplete: self.ad?.percentProgress = 100
        default: break
        }
    }
    
    func updateForNextEvent(eventType: MediaEventType) {
        switch (eventType) {
        case .adBreakEnd:
            self.adBreak = nil
            self.podPosition = 0
        case .adComplete, .adSkip:
            self.ad = nil
        default: break
        }
    }
}
