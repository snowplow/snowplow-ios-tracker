//
//  ScreenView.swift
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

/// An enum for screen types.
@objc(SPScreenType)
public enum ScreenType : Int {
    // sourced from `View Controller Catalog for iOS`
    case `default`
    case navigation
    case tabBar
    case pageView
    case splitView
    case popoverPresentation
    case modal
    case combined
}

/// A screenview event.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/screen_view/jsonschema/1-0-0`
@objc(SPScreenView)
public class ScreenView: SelfDescribingAbstract {
    /// Name of the screen.
    @objc
    public var name: String
    /// Identifier of the screen.
    @objc
    public var screenId: UUID
    /// Type of screen.
    @objc
    public var type: String?
    /// Name of the previous screen.
    @objc
    public var previousName: String?
    /// Identifier of the previous screen.
    @objc
    public var previousId: String?
    /// Type of the previous screen.
    @objc
    public var previousType: String?
    /// Type of transition between previous and current screen,
    @objc
    public var transitionType: String?
    /// Name of the ViewController subclass.
    @objc
    public var viewControllerClassName: String?
    /// Name of the top ViewController subclass.
    @objc
    public var topViewControllerClassName: String?

    /// Creates a screenview event.
    /// - Parameter name: Name of the screen.
    /// - Parameter screenId: Identifier of the screen.
    @objc
    public init(name: String, screenId: UUID?) {
        self.screenId = screenId ?? UUID()
        self.name = name
    }

    override var schema: String {
        return kSPScreenViewSchema
    }

    override var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPSvName] = name as NSObject
        payload[kSPSvScreenId] = screenId.uuidString as NSObject
        if let type = type { payload[kSPSvType] = type as NSObject }
        if let previousName = previousName { payload[kSPSvPreviousName] = previousName as NSObject }
        if let previousType = previousType { payload[kSPSvPreviousType] = previousType as NSObject }
        if let previousId = previousId { payload[kSPSvPreviousScreenId] = previousId as NSObject }
        if let transitionType = transitionType { payload[kSPSvTransitionType] = transitionType as NSObject }
        return payload
    }

    class func stringWithScreenType(_ screenType: ScreenType) -> String? {
        let arr = [
            "Default",
            "Navigation",
            "TabBar",
            "PageView",
            "SplitView",
            "PopoverPresentation",
            "Modal",
            "Combined"
        ];
        return arr[screenType.rawValue];
    }
}
