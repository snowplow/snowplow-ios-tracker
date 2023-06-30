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

fileprivate struct Log {
    var time: Date
    var contentTime: Double
    var playbackRate: Double
    var paused: Bool
    var muted: Bool
    var linearAd: Bool
}

class MediaSessionTrackingStats {
    private var session: MediaSessionEntity
    private var dateGenerator: () -> Date
    private var lastAdUpdateAt: Date?
    private var bufferingStartedAt: Date?
    private var bufferingStartTime: Double?
    private var playbackDurationWithPlaybackRate = TimeInterval(0)
    private var playedSeconds: Set<Int> = Set()
    private var lastLog: Log?
    
    var contentWatched: Int { return playedSeconds.count }
    var timeSpentAds = TimeInterval(0)
    var timePlayed = TimeInterval(0)
    var timePlayedMuted = TimeInterval(0)
    var timePaused = TimeInterval(0)
    var timeBuffering = TimeInterval(0)
    var avgPlaybackRate: Double {
        return timePlayed > 0 ? playbackDurationWithPlaybackRate / timePlayed : 1
    }
    var adBreaks = 0
    var ads = 0
    var adsSkipped = 0
    var adsClicked = 0
    
    init(session: MediaSessionEntity, dateGenerator: @escaping () -> Date = Date.init) {
        self.session = session
        self.dateGenerator = dateGenerator
    }
    
    func update(event: Event?, player: MediaPlayerEntity, adBreak: MediaAdBreakEntity? = nil) {
        let log = Log(
            time: dateGenerator(),
            contentTime: player.currentTime ?? 0,
            playbackRate: player.playbackRate ?? 1,
            paused: player.paused ?? true,
            muted: player.muted ?? false,
            linearAd: adBreak?.breakType ?? .linear == .linear
        )
        
        updateDurationStats(log: log)
        updateAdStats(event: event, log: log)
        updateBufferingStats(event: event, log: log)
        
        lastLog = log
    }
    
    private func updateDurationStats(log: Log) {
        let wasPlayingAd = lastAdUpdateAt != nil
        let shouldCountStats = !wasPlayingAd || !log.linearAd
        
        guard shouldCountStats else { return }
        
        if let lastLog = lastLog {
            // add the time diff since last event to duration stats
            let duration = timeDiff(since: lastLog.time, until: log.time)
            if lastLog.paused {
                timePaused += duration
            } else {
                timePlayed += duration
                playbackDurationWithPlaybackRate += duration * lastLog.playbackRate
                
                if lastLog.muted {
                    timePlayedMuted += duration
                }
                
                if !log.paused && log.contentTime > lastLog.contentTime {
                    for i in Int(lastLog.contentTime)..<Int(log.contentTime) {
                        playedSeconds.insert(i)
                    }
                }
            }
        }
        
        if !log.paused {
            playedSeconds.insert(Int(log.contentTime))
        }
    }
    
    private func updateAdStats(event: Event?, log: Log) {
        // count ad actions
        switch event {
        case is MediaAdBreakStartEvent:
            adBreaks += 1
            
        case is MediaAdStartEvent:
            ads += 1
            
        case is MediaAdSkipEvent:
            adsSkipped += 1
            
        case is MediaAdClickEvent:
            adsClicked += 1
            
        default: break
        }
        
        // update ad playback duration
        switch event {
        case is MediaAdStartEvent, is MediaAdResumeEvent: // ad start
            if lastAdUpdateAt == nil {
                lastAdUpdateAt = log.time
            }
            
        case is MediaAdClickEvent, is MediaAdFirstQuartileEvent, is MediaAdMidpointEvent, is MediaAdThirdQuartileEvent: // ad progress
            if let lastAdUpdateAt = lastAdUpdateAt {
                timeSpentAds += timeDiff(since: lastAdUpdateAt, until: log.time)
            }
            lastAdUpdateAt = log.time
            
        case is MediaAdCompleteEvent, is MediaAdSkipEvent, is MediaAdPauseEvent: // ad end
            if let lastAdUpdateAt = lastAdUpdateAt {
                timeSpentAds += timeDiff(since: lastAdUpdateAt, until: log.time)
            }
            lastAdUpdateAt = nil
            
        default: break
        }
    }
    
    private func updateBufferingStats(event: Event?, log: Log) {
        if event is MediaBufferStartEvent {
            bufferingStartedAt = log.time
            bufferingStartTime = log.contentTime
        } else if let bufferingStartedAt = bufferingStartedAt,
                  let bufferingStartTime = bufferingStartTime {
            if (log.contentTime != bufferingStartTime && !log.paused) ||
                (event is MediaBufferEndEvent || event is MediaPlayEvent) {
                // Either the playback moved or BufferEnd or Play events were tracked
                timeBuffering += timeDiff(since: bufferingStartedAt, until: log.time)
                self.bufferingStartTime = nil
                self.bufferingStartedAt = nil
            } else {
                // Still buffering, just update the ongoing duration
                timeBuffering += timeDiff(since: bufferingStartedAt, until: log.time)
                self.bufferingStartedAt = log.time
            }
        }
    }
    
    private func timeDiff(since: Date, until: Date) -> TimeInterval {
        return until.timeIntervalSince1970 - since.timeIntervalSince1970
    }
}
