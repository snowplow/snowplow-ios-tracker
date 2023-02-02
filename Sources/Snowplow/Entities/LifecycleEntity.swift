// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.

import Foundation

let kSPLifecycleEntitySchema = "iglu:com.snowplowanalytics.mobile/application_lifecycle/jsonschema/1-0-0"
let kSPLifecycleEntityParamIndex = "index"
let kSPLifecycleEntityParamIsVisible = "isVisible"

/// Entity that indicates the state of the app is visible (foreground) when the event is tracked.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/application_lifecycle/jsonschema/1-0-0`
@objc(SPLifecycleEntity)
public class LifecycleEntity: SelfDescribingJson {

    /// - Parameters:
    ///    - isVisible: Indicates if the app is in foreground state (true) or background state (false)
    @objc
    public init(isVisible: Bool) {
        var parameters: [String : Any] = [:]
        parameters[kSPLifecycleEntityParamIsVisible] = isVisible
        super.init(schema: kSPLifecycleEntitySchema, andData: parameters)
    }

    /// Represents the foreground index or background index (tracked with com.snowplowanalytics.snowplow application_foreground and application_background events.
    @objc
    public var index: NSNumber? {
        set {
            data[kSPLifecycleEntityParamIndex] = newValue?.intValue
        }
        get {
            if let value = data[kSPLifecycleEntityParamIndex] as? Int {
                return NSNumber(value: value)
            }
            return nil
        }
    }
    
    // MARK: - Builders
    
    /// Represents the foreground index or background index (tracked with com.snowplowanalytics.snowplow application_foreground and application_background events.
    public func index(_ index: NSNumber?) -> Self {
        self.index = index
        return self
    }
}
