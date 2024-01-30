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

import XCTest
@testable import SnowplowTracker

class TestVisionOSEntities: XCTestCase {
    let uuid = UUID()
    
    func testBuildsImmersiveSpaceEntity() {
        let space = ImmersiveSpaceEntity(
            id: "space_123",
            viewId: uuid,
            immersionStyle: ImmersionStyle.automatic,
            upperLimbVisibility: UpperLimbVisibility.visible
        )
        let entity = space.data
        
        XCTAssertEqual(swiftuiImmersiveSpaceSchema, space.schema)
        XCTAssertEqual("space_123", entity["id"] as? String)
        XCTAssertEqual(uuid.uuidString, entity["view_id"] as? String)
        XCTAssertEqual("automatic", entity["immersion_style"] as? String)
        XCTAssertEqual("visible", entity["upper_limb_visibility"] as? String)
    }
    
    func testBuildsWindowGroupEntity() {
        let windows = WindowGroupEntity(
            id: "group_id",
            windowId: uuid,
            titleKey: "title",
            windowStyle: .plain
        )
        let entity = windows.data
        
        XCTAssertEqual(swiftuiWindowGroupSchema, windows.schema)
        XCTAssertEqual("group_id", entity["id"] as? String)
        XCTAssertEqual(uuid.uuidString, entity["window_id"] as? String)
        XCTAssertEqual("title", entity["title_key"] as? String)
        XCTAssertEqual("plain", entity["window_style"] as? String)
    }
}
