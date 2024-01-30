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
@testable import SnowplowTracker

class MockTimer: InternalQueueTimer {
    
    var block: (() -> Void)
    
    init(block: @escaping () -> Void) {
        self.block = block
    }
    
    static var currentTimer: MockTimer!
    
    func fire() {
        InternalQueue.sync {
            block()
        }
    }
    
    static func startTimer(_ interval: TimeInterval,
                           _ block: @escaping () -> Void) -> InternalQueueTimer {
        let mockTimer = MockTimer(block: block)
        mockTimer.block = block
        
        MockTimer.currentTimer = mockTimer
        
        return mockTimer
    }
}
