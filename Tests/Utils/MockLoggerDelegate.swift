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
@testable import SnowplowTracker

class MockLoggerDelegate: NSObject, LoggerDelegate {
    var errorLogs: [String] = []
    var debugLogs: [String] = []
    var verboseLogs: [String] = []

    func debug(_ tag: String, message: String) {
        debugLogs.append(message)
    }

    func error(_ tag: String, message: String) {
        errorLogs.append(message)
    }

    func verbose(_ tag: String, message: String) {
        verboseLogs.append(message)
    }
}
