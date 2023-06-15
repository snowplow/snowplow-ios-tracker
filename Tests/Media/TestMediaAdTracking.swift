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

import XCTest
@testable import SnowplowTracker

class TestMediaAdTracking: XCTestCase {
    
    func testUpdatesStartTimeOfAdBreak() {
        let adTracking = MediaAdTracking()
        
        adTracking.updateForThisEvent(event: MediaAdBreakStartEvent(),
                                      player: MediaPlayerEntity().currentTime(33.0),
                                      ad: nil,
                                      adBreak: MediaAdBreakEntity(breakId: "b1"))
        adTracking.updateForNextEvent(event: MediaAdBreakStartEvent())
        
        adTracking.updateForThisEvent(event: MediaAdStartEvent(),
                                      player: MediaPlayerEntity().currentTime(44.0),
                                      ad: MediaAdEntity(adId: "a1"),
                                      adBreak: nil)
        adTracking.updateForNextEvent(event: MediaAdStartEvent())
        
        XCTAssertEqual("b1", adTracking.adBreak?.breakId)
        XCTAssertEqual(33.0, adTracking.adBreak?.startTime)
    }
    
    func testUpdatesPodPositionOfAds() {
        let adTracking = MediaAdTracking()
        
        adTracking.updateForThisEvent(event: MediaAdBreakStartEvent(),
                                      player: MediaPlayerEntity(),
                                      ad: nil,
                                      adBreak: MediaAdBreakEntity(breakId: "b1"))
        adTracking.updateForNextEvent(event: MediaAdBreakStartEvent())
        
        adTracking.updateForThisEvent(event: MediaAdStartEvent(),
                                      player: MediaPlayerEntity(),
                                      ad: MediaAdEntity(adId: "a1"),
                                      adBreak: nil)
        
        XCTAssertEqual(1, adTracking.ad?.podPosition)
        
        adTracking.updateForNextEvent(event: MediaAdStartEvent())
        
        adTracking.updateForThisEvent(event: MediaAdStartEvent(),
                                      player: MediaPlayerEntity(),
                                      ad: MediaAdEntity(adId: "a2"),
                                      adBreak: nil)
        
        XCTAssertEqual(2, adTracking.ad?.podPosition)
    }
}
