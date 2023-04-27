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
        
        adTracking.updateForThisEvent(eventType: .adBreakStart,
                                      mediaPlayer: MediaUpdate().currentTime(33.0),
                                      ad: nil,
                                      adBreak: MediaAdBreakUpdate(breakId: "b1"))
        adTracking.updateForNextEvent(eventType: .adBreakStart)
        
        adTracking.updateForThisEvent(eventType: .adStart,
                                      mediaPlayer: MediaUpdate().currentTime(44.0),
                                      ad: MediaAdUpdate(adId: "a1"),
                                      adBreak: nil)
        adTracking.updateForNextEvent(eventType: .adStart)
        
        XCTAssertEqual("b1", adTracking.adBreak?.breakId)
        XCTAssertEqual(33.0, adTracking.adBreak?.startTime)
    }
    
    func testUpdatesPodPositionOfAds() {
        let adTracking = MediaAdTracking()
        
        adTracking.updateForThisEvent(eventType: .adBreakStart,
                                      mediaPlayer: MediaUpdate(),
                                      ad: nil,
                                      adBreak: MediaAdBreakUpdate(breakId: "b1"))
        adTracking.updateForNextEvent(eventType: .adBreakStart)
        
        adTracking.updateForThisEvent(eventType: .adStart,
                                      mediaPlayer: MediaUpdate(),
                                      ad: MediaAdUpdate(adId: "a1"),
                                      adBreak: nil)
        
        XCTAssertEqual(1, adTracking.ad?.podPosition)
        
        adTracking.updateForNextEvent(eventType: .adStart)
        
        adTracking.updateForThisEvent(eventType: .adStart,
                                      mediaPlayer: MediaUpdate(),
                                      ad: MediaAdUpdate(adId: "a1"),
                                      adBreak: nil)
        
        XCTAssertEqual(2, adTracking.ad?.podPosition)
    }
    
    func testUpdatesPercentProgressOfAds() {
        let adTracking = MediaAdTracking()
        
        adTracking.updateForThisEvent(eventType: .adStart,
                                      mediaPlayer: MediaUpdate(),
                                      ad: MediaAdUpdate(adId: "a1").duration(100),
                                      adBreak: nil)
        
        XCTAssertEqual(0, adTracking.ad?.percentProgress)
        
        adTracking.updateForNextEvent(eventType: .adStart)
        adTracking.updateForThisEvent(eventType: .adFirstQuartile,
                                      mediaPlayer: MediaUpdate(),
                                      ad: nil,
                                      adBreak: nil)
        
        XCTAssertEqual(25, adTracking.ad?.percentProgress)
        
        adTracking.updateForNextEvent(eventType: .adFirstQuartile)
        adTracking.updateForThisEvent(eventType: .adMidpoint,
                                      mediaPlayer: MediaUpdate(),
                                      ad: nil,
                                      adBreak: nil)
        
        XCTAssertEqual(50, adTracking.ad?.percentProgress)
        
        adTracking.updateForNextEvent(eventType: .adMidpoint)
        adTracking.updateForThisEvent(eventType: .adThirdQuartile,
                                      mediaPlayer: MediaUpdate(),
                                      ad: nil,
                                      adBreak: nil)
        
        
        XCTAssertEqual(75, adTracking.ad?.percentProgress)
        
        adTracking.updateForNextEvent(eventType: .adThirdQuartile)
        adTracking.updateForThisEvent(eventType: .adComplete,
                                      mediaPlayer: MediaUpdate(),
                                      ad: nil,
                                      adBreak: nil)
        
        XCTAssertEqual(100, adTracking.ad?.percentProgress)
    }
}
