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

/// Event tracked when a screen is no longer visible to the user.
///
/// This event is tracked automatically before each `ScreenView` event when screen engagement
/// tracking is enabled, closing out the engagement summary for the previous screen.
///
/// It can also be tracked manually to end the current screen without starting a new one –
/// for instance when a WebView is presented over a native screen, or when a screen is
/// dismissed without a subsequent screen view being tracked. Tracking it manually stops the
/// engagement timer for the current screen and attaches the `screen_summary` entity.
///
/// The event is not tracked if there is no current screen to end.
public class ScreenEnd: SelfDescribingAbstract {

    public override init() {
        super.init()
    }

    override var schema: String {
        return kSPScreenEndSchema
    }

    override var payload: [String : Any] {
        return [:]
    }

}
