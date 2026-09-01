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

/// An event to manually end the currently active screen view.
///
/// Use this when a screen stops being actually visible in a way the tracker can't detect
/// automatically — e.g. a WebView using its own tracker is presented on top of a native screen.
/// Without this, the native screen would keep accumulating engagement metrics and have
/// subsequent native events attributed to it even though it's no longer in view.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/end_screen_view/jsonschema/1-0-0`
@objc(SPEndScreenView)
public class EndScreenView: SelfDescribingAbstract {
    /// Identifier of the screen view to end.
    ///
    /// If provided and it doesn't match the currently active screen view, the event is ignored —
    /// this guards against a delayed/stale call corrupting the state of a screen the user has
    /// already natively navigated to since.
    @objc
    public var screenId: UUID?

    /// Creates an event to manually end the currently active screen view.
    /// - Parameter screenId: Identifier of the screen view to end (optional).
    @objc
    public init(screenId: UUID? = nil) {
        self.screenId = screenId
    }

    override var schema: String {
        return kSPEndScreenViewSchema
    }

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        if let screenId = screenId { payload[kSPSvScreenId] = screenId.uuidString }
        return payload
    }
}
