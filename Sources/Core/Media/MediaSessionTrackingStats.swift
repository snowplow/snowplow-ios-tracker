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
    var eventType: MediaEventType?
    var playbackRate: Double
    var paused: Bool
    var muted: Bool
    var linearAd: Bool
}

class MediaSessionTrackingStats {
    private var session: MediaPlayerSession
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
    
    init(session: MediaPlayerSession, dateGenerator: @escaping () -> Date = Date.init) {
        self.session = session
        self.dateGenerator = dateGenerator
    }
    
    func update(eventType: MediaEventType?, mediaPlayer: MediaUpdate, adBreak: MediaAdBreakUpdate? = nil) {
        let log = Log(
            time: dateGenerator(),
            contentTime: mediaPlayer.currentTime ?? 0,
            eventType: eventType,
            playbackRate: mediaPlayer.playbackRate ?? 1,
            paused: mediaPlayer.paused ?? true,
            muted: mediaPlayer.muted ?? false,
            linearAd: adBreak?.breakType ?? .linear == .linear
        )
        
        updateDurationStats(log: log)
        updateAdStats(log: log)
        updateBufferingStats(log: log)
        
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
    
    private func updateAdStats(log: Log) {
        // only works with ad event types
        guard let eventType = log.eventType else { return }
        
        // count ad actions
        switch eventType {
        case .adBreakStart:
            adBreaks += 1
        case .adStart:
            ads += 1
        case .adSkip:
            adsSkipped += 1
        case .adClick:
            adsClicked += 1
        default: break
        }
        
        // update ad playback duration
        switch eventType {
        case .adStart, .adResume: // ad start
            if lastAdUpdateAt == nil {
                lastAdUpdateAt = log.time
            }
            
        case .adClick, .adFirstQuartile, .adMidpoint, .adThirdQuartile: // ad progress
            if let lastAdUpdateAt = lastAdUpdateAt {
                timeSpentAds += timeDiff(since: lastAdUpdateAt, until: log.time)
            }
            lastAdUpdateAt = log.time
            
        case .adComplete, .adSkip, .adPause: // ad end
            if let lastAdUpdateAt = lastAdUpdateAt {
                timeSpentAds += timeDiff(since: lastAdUpdateAt, until: log.time)
            }
            lastAdUpdateAt = nil
            
        default: break
        }
    }
    
    private func updateBufferingStats(log: Log) {
        if log.eventType == .bufferStart {
            bufferingStartedAt = log.time
            bufferingStartTime = log.contentTime
        } else if let bufferingStartedAt = bufferingStartedAt,
                  let bufferingStartTime = bufferingStartTime {
            if (log.contentTime != bufferingStartTime && !log.paused) ||
                (log.eventType == .bufferEnd || log.eventType == .play) {
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
