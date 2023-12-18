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

class TestVisionOSSerialisation: XCTestCase {
    let id = UUID()
    
    func testBuildsImmersiveSpaceEntity() {
        let space = ImmersiveSpaceEntity(
            id: id,
            immersiveSpaceId: "space_123",
            immersionStyle: ImmersionStyle.automatic,
            upperLimbVisibility: UpperLimbVisibility.visible
        )
        let entity = space.data
        
        XCTAssertEqual(visionOsImmersiveSpace, space.schema)
        XCTAssertEqual(id.uuidString, entity["id"] as? String)
        XCTAssertEqual("space_123", entity["immersive_space_id"] as? String)
        XCTAssertEqual("automatic", entity["immersion_style"] as? String)
        XCTAssertEqual("visible", entity["upper_limb_visibility"] as? String)
    }
    
    func testBuildsWindowGroupEntity() {
        let windows = WindowGroupEntity(
            id: id,
            titleKey: "title",
            windowGroupID: "group_id",
            windowStyle: .plain
        )
        let entity = windows.data
        
        XCTAssertEqual(visionOsWindowGroup, windows.schema)
        XCTAssertEqual(id.uuidString, entity["id"] as? String)
        XCTAssertEqual("title", entity["title_key"] as? String)
        XCTAssertEqual("group_id", entity["window_group_id"] as? String)
        XCTAssertEqual("plain", entity["window_style"] as? String)
    }
}
