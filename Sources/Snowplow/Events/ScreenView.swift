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
    public init(name: String, screenId: UUID? = nil) {
        self.screenId = screenId ?? UUID()
        self.name = name
    }

    override var schema: String {
        return kSPScreenViewSchema
    }

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        payload[kSPSvName] = name
        payload[kSPSvScreenId] = screenId.uuidString
        if let type = type { payload[kSPSvType] = type }
        if let previousName = previousName { payload[kSPSvPreviousName] = previousName }
        if let previousType = previousType { payload[kSPSvPreviousType] = previousType }
        if let previousId = previousId { payload[kSPSvPreviousScreenId] = previousId }
        if let transitionType = transitionType { payload[kSPSvTransitionType] = transitionType }
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
    
    // MARK: - Builders
    
    /// Type of screen.
    @objc
    public func type(_ type: String?) -> Self {
        self.type = type
        return self
    }
    
    /// Name of the previous screen.
    @objc
    public func previousName(_ previousName: String?) -> Self {
        self.previousName = previousName
        return self
    }
    
    /// Identifier of the previous screen.
    @objc
    public func previousId(_ previousId: String?) -> Self {
        self.previousId = previousId
        return self
    }
    
    /// Type of the previous screen.
    @objc
    public func previousType(_ previousType: String?) -> Self {
        self.previousType = previousType
        return self
    }
    
    /// Type of transition between previous and current screen,
    @objc
    public func transitionType(_ transitionType: String?) -> Self {
        self.transitionType = transitionType
        return self
    }
    
    /// Name of the ViewController subclass.
    @objc
    public func viewControllerClassName(_ viewControllerClassName: String?) -> Self {
        self.viewControllerClassName = viewControllerClassName
        return self
    }
    
    /// Name of the top ViewController subclass.
    @objc
    public func topViewControllerClassName(_ topViewControllerClassName: String?) -> Self {
        self.topViewControllerClassName = topViewControllerClassName
        return self
    }
}
