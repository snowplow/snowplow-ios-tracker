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

import Foundation

/// Lifecycle of the current screen.
enum ScreenLifecycle {
    /// The screen is visible, its entity is attached to all events.
    case active
    /// The screen was just ended, its entity is attached only to the `ScreenEnd` event that ended it.
    case ending
    /// The screen was ended earlier, its entity is no longer attached to events.
    case ended
}

/// Forward declaration for SPScreenView
class ScreenState: NSObject, State, NSCopying {
    /// Screenview name
    private(set) var name: String
    /// Screen ID
    private(set) var screenId: String
    /// Screen type
    private(set) var type: String?
    /// Screenview transition type
    private(set) var transitionType: String?
    /// Top view controller class name
    private(set) var topViewControllerClassName: String?
    /// View controller class name
    private(set) var viewControllerClassName: String?
    /// Previous ScreenState
    var previousState: ScreenState?
    /// Whether the screen is still visible or was ended using a `ScreenEnd` event
    private(set) var lifecycle: ScreenLifecycle = .active

    /// Creates a new screen state.
    /// - Parameters:
    ///   - theName: A name to identify the screen view
    ///   - theType: The type of the screen view
    ///   - theScreenId: An ID generated for the screen
    ///   - theTransitionType: The transition used to arrive at the screen
    ///   - theTopControllerName: The top view controller class name
    ///   - theControllerName: The view controller class name
    required init(name theName: String, type theType: String?, screenId theScreenId: String?, transitionType theTransitionType: String?, topViewControllerClassName theTopControllerName: String?, viewControllerClassName theControllerName: String?) {
        name = theName
        if theScreenId == nil {
            screenId = UUID().uuidString
        } else {
            screenId = theScreenId ?? ""
        }
        type = theType
        transitionType = theTransitionType
        topViewControllerClassName = theTopControllerName
        viewControllerClassName = theControllerName
    }

    convenience init(name theName: String, type theType: String?, topViewControllerClassName theTopControllerName: String?, viewControllerClassName theControllerName: String?) {
        self.init(name: theName, type: theType, screenId: nil, transitionType: nil, topViewControllerClassName: theTopControllerName, viewControllerClassName: theControllerName)
    }

    convenience init(name theName: String, type theType: String?, screenId theScreenId: String?, transitionType theTransitionType: String?) {
        self.init(name: theName, type: theType, screenId: theScreenId, transitionType: nil, topViewControllerClassName: nil, viewControllerClassName: nil)
    }

    convenience init(name theName: String, type theType: String?, screenId theScreenId: String?) {
        self.init(name: theName, type: theType, screenId: theScreenId, transitionType: nil)
    }

    convenience init(name theName: String, screenId theScreenId: String?) {
        self.init(name: theName, type: nil, screenId: theScreenId, transitionType: nil)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return ScreenState(name: name,
                           type: type,
                           screenId: screenId,
                           transitionType: transitionType,
                           topViewControllerClassName: topViewControllerClassName,
                           viewControllerClassName: viewControllerClassName)
    }

    /// Returns a copy of the state for a screen that was ended by a `ScreenEnd` event.
    /// The first `ScreenEnd` moves the screen to `.ending`, any later one to `.ended`.
    func ended() -> ScreenState {
        let endedState = ScreenState(name: name,
                                     type: type,
                                     screenId: screenId,
                                     transitionType: transitionType,
                                     topViewControllerClassName: topViewControllerClassName,
                                     viewControllerClassName: viewControllerClassName)
        endedState.lifecycle = lifecycle == .active ? .ending : .ended
        return endedState
    }

    /// Return if the state is valid.
    var isValid: Bool {
        return (Utilities.validate(name) != nil) && (Utilities.validate(screenId) != nil) && Utilities.isUUIDString(screenId)
    }

    /// Returns all non-nil values if the state is valid (e.g. name is not missing or empty string).
    var payload: Payload? {
        if isValid {
            let validPayload = Payload()
            validPayload.addValueToPayload(name, forKey: kSPScreenName)
            validPayload.addValueToPayload(screenId, forKey: kSPScreenId)
            validPayload.addValueToPayload(type, forKey: kSPScreenType)
            validPayload.addValueToPayload(topViewControllerClassName, forKey: kSPScreenTopViewController)
            validPayload.addValueToPayload(viewControllerClassName, forKey: kSPScreenViewController)
            return validPayload
        }
        return nil
    }
}
