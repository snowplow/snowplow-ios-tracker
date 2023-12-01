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

class MediaPingInterval {
    var pingInterval: Int
    
    private var timer: InternalQueueTimer?
    private var startTimer: (TimeInterval, @escaping () -> Void) -> InternalQueueTimer
    private var paused: Bool?
    private var numPausedPings: Int = 0
    private var maxPausedPings: Int = 1
    private var isPaused: Bool { paused == true }
    
    init(pingInterval: Int? = nil,
         maxPausedPings: Int? = nil,
         startTimer: @escaping (TimeInterval, @escaping () -> Void) -> InternalQueueTimer = InternalQueue.startTimer) {
        if let maxPausedPings = maxPausedPings {
            self.maxPausedPings = maxPausedPings
        }
        self.pingInterval = pingInterval ?? 30
        self.startTimer = startTimer
    }
    
    func update(player: MediaPlayerEntity) {
        paused = player.paused ?? true
        if paused == false { numPausedPings = 0 }
    }
    
    func subscribe(callback: @escaping () -> ()) {
        end()
        
        timer = startTimer(TimeInterval(pingInterval)) { [weak self] in
            guard let self = self else { return }
            if !self.isPaused || self.numPausedPings < self.maxPausedPings {
                if self.isPaused {
                    self.numPausedPings += 1
                }
                callback()
            }
        }
    }
    
    func end() {
        timer?.invalidate()
        timer = nil
    }
}
