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
 
/// Configuration object for ``TrackerController/decorateLink``
@objc public class CrossDeviceParameterConfiguration : NSObject {
    /// Whether to include the value of ``SessionController.sessionId`` when decorating a link (enabled by default)
    @objc var sessionId: Bool
    /// Whether to include the value of ``Subject.userId`` when decorating a link
    @objc var subjectUserId: Bool
    /// Whether to include the value of ``Tracker.appId``  when decorating a link (enabled by default)
    @objc var sourceId: Bool
    /// Whether to include the value of ``Tracker.platform`` when  decorating a link
    @objc var sourcePlatform: Bool
    /// Optional identifier/information for cross-navigation
    @objc var reason: String?
    
    @objc init(
        sessionId: Bool = true,
        subjectUserId: Bool = false,
        sourceId: Bool = true,
        sourcePlatform: Bool = false,
        reason: String? = nil
    ) {
        self.sessionId = sessionId
        self.subjectUserId = subjectUserId
        self.sourceId = sourceId
        self.sourcePlatform = sourcePlatform
        self.reason = reason
    }
}
