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

/// An enum for buffer options.
@objc(SPBufferOption)
public enum BufferOption : Int {
    /// Sends both GET and POST requests with only a single event.  Can cause a spike in
    /// network traffic if used in correlation with a large amount of events.
    case single = 1
    /// Sends POST requests in groups of 10 events.  This is the default amount of events too
    /// package into a POST.  All GET requests will still emit one at a time.
    case defaultGroup = 10
    /// Sends POST requests in groups of 25 events.  Useful for situations where many events
    /// need to be sent.  All GET requests will still emit one at a time.
    case largeGroup = 25
}

extension BufferOption {
    static func fromString(value: String) -> BufferOption? {
        switch value {
        case "Single":
            return .single
        case "DefaultGroup":
            return .defaultGroup
        case "HeavyGroup":
            return .largeGroup
        default:
            return nil
        }
    }
}
