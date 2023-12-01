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

class InternalQueue {
    static func sync<T>(_ callback: () -> T) -> T {
        dispatchPrecondition(condition: .notOnQueue(serialQueue))

        return serialQueue.sync(execute: callback)
    }
    
    static func async(_ callback: @escaping () -> Void) {
        serialQueue.async(execute: callback)
    }
    
    static func asyncAfter(_ interval: TimeInterval, _ callback: @escaping () -> Void) {
        serialQueue.asyncAfter(deadline: .now() + interval, execute: callback)
    }
    
    static func startTimer(_ interval: TimeInterval, _ callback: @escaping () -> Void) -> InternalQueueTimer {
        let timer = InternalQueueTimer()
        
        asyncAfter(interval) {
            timerFired(timer: timer, interval: interval, callback: callback)
        }
        
        return timer
    }
    
    static private func timerFired(timer: InternalQueueTimer, interval: TimeInterval, callback: @escaping () -> Void) {
        if timer.active {
            asyncAfter(interval) {
                timerFired(timer: timer, interval: interval, callback: callback)
            }
            
            callback()
        }
    }
    
    static func onQueuePrecondition() {
        dispatchPrecondition(condition: .onQueue(serialQueue))
    }
    
    private static let serialQueue = DispatchQueue(label: "snowplow")
}
