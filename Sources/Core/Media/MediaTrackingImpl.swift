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

class MediaTrackingImpl: MediaTracking {
    var id: String
    var label: String?

    private var session: MediaSessionTracking?
    private var adTracking = MediaAdTracking()
    private var mediaPlayer = MediaUpdate()
    private var pingInterval: MediaPingInterval?
    private var sentBoundaries: [Int] = []
    private var seeking = false
    private var tracker: TrackerController
    private var captureEvents: [MediaEventType]?
    private var customEntities: [SelfDescribingJson]?
    private var boundaries: [Int]?
    
    private var entities: [SelfDescribingJson] {
        var entities = [
            self.mediaPlayer.entity
        ]
        if let entity = self.session?.entity { entities.append(entity) }
        entities += self.adTracking.entities
        if let customEntities = customEntities {
            entities += customEntities
        }
        return entities
    }
    
    init(id: String,
         tracker: TrackerController,
         label: String? = nil,
         mediaPlayer: MediaUpdate? = nil,
         session: MediaSessionTracking? = nil,
         pingInterval: MediaPingInterval? = nil,
         boundaries: [Int]? = nil,
         captureEvents: [MediaEventType]? = nil,
         entities: [SelfDescribingJson]? = nil,
         dateGenerator: @escaping () -> Date = Date.init) {
        self.id = id
        self.tracker = tracker
        self.label = label
        self.boundaries = boundaries
        self.pingInterval = pingInterval
        self.captureEvents = captureEvents
        self.session = session
        self.customEntities = entities
        
        if let mediaPlayer = mediaPlayer {
            self.mediaPlayer.update(from: mediaPlayer)
        }
        
        self.pingInterval?.subscribe {
            self.trackEvent(eventType: .ping)
        }
    }
    
    func end() {
        self.pingInterval?.end()
    }
    
    // MARK: Update methods overloads
    
    func update(media: MediaUpdate?) {
        self.update(mediaPlayer: media)
    }
    
    func update(media: MediaUpdate?,
                ad: MediaAdUpdate?,
                adBreak: MediaAdBreakUpdate?) {
        self.update(mediaPlayer: media, ad: ad, adBreak: adBreak)
    }
    
    // MARK: Track methods overloads
    
    func track(_ eventType: MediaEventType) {
        self.track(eventType, media: nil, ad: nil, adBreak: nil)
    }
    
    func track(_ eventType: MediaEventType, media: MediaUpdate?) {
        self.track(eventType, media: media, ad: nil, adBreak: nil)
    }
    
    func track(_ eventType: MediaEventType, ad: MediaAdUpdate?) {
        self.track(eventType, media: nil, ad: ad, adBreak: nil)
    }
    
    func track(_ eventType: MediaEventType, media: MediaUpdate?, ad: MediaAdUpdate?) {
        self.track(eventType, media: media, ad: ad, adBreak: nil)
    }
    
    func track(_ eventType: MediaEventType, adBreak: MediaAdBreakUpdate?) {
        self.track(eventType, media: nil, ad: nil, adBreak: adBreak)
    }
    
    func track(_ eventType: MediaEventType, media: MediaUpdate?, adBreak: MediaAdBreakUpdate?) {
        self.track(eventType, media: media, ad: nil, adBreak: adBreak)
    }
    
    func track(_ eventType: MediaEventType, media: MediaUpdate?, ad: MediaAdUpdate?, adBreak: MediaAdBreakUpdate?) {
        self.track(event: MediaEvent(eventType, media: media, ad: ad, adBreak: adBreak))
    }
    
    func track(event: MediaEvent) {
        self.update(eventType: event.eventType,
                    mediaPlayer: event.media,
                    ad: event.ad,
                    adBreak: event.adBreak,
                    eventEntities: event.entities)
    }
    
    // MARK: Private methods
    
    private func update(eventType: MediaEventType? = nil,
                        mediaPlayer: MediaUpdate? = nil,
                        ad: MediaAdUpdate? = nil,
                        adBreak: MediaAdBreakUpdate? = nil,
                        eventEntities: [SelfDescribingJson]? = nil) {
        // update state
        if let mediaPlayer = mediaPlayer {
            self.mediaPlayer.update(from: mediaPlayer)
        }
        if let eventType = eventType {
            self.mediaPlayer.update(with: eventType)
            adTracking.updateForThisEvent(eventType: eventType,
                                          mediaPlayer: self.mediaPlayer,
                                          ad: ad,
                                          adBreak: adBreak)
        }
        self.session?.update(eventType: eventType,
                             mediaPlayer: self.mediaPlayer,
                             adBreak: adTracking.adBreak)
        self.pingInterval?.update(mediaPlayer: self.mediaPlayer)
        
        // track events
        if let eventType = eventType {
            trackEvent(eventType: eventType, eventEntities: eventEntities)
        }
        if shouldSendPercentProgress() {
            trackEvent(eventType: .percentProgress)
        }
        
        // update state for events after this one
        if let eventType = eventType {
            adTracking.updateForNextEvent(eventType: eventType)
        }
    }
    
    private func trackEvent(eventType: MediaEventType, eventEntities: [SelfDescribingJson]? = nil) {
        guard shouldTrackEvent(eventType) else { return }
        
        var data: [String : Any] = [:]
        if let label = label { data["label"] = label }
        
        let event = SelfDescribing(schema: eventType.schema, payload: data)
        event.entities = entities + (eventEntities ?? [])
        
        _ = self.tracker.track(event)
    }
    
    private func shouldSendPercentProgress() -> Bool {
        if mediaPlayer.paused ?? true { return false }
        guard let boundaries = boundaries,
              let percentProgress = mediaPlayer.percentProgress else { return false }
        
        let achievedBoundaries = boundaries.filter { $0 <= percentProgress }
        
        if let boundary = achievedBoundaries.max() {
            if !sentBoundaries.contains(boundary) {
                sentBoundaries.append(boundary)
                return true
            }
        }
        
        return false
    }
    
    private func shouldTrackEvent(_ eventType: MediaEventType) -> Bool {
        if eventType == .seekStart {
            if seeking {
               return false
            }
            seeking = true
        } else if eventType == .seekEnd {
            seeking = false
        }
        
        if let captureEvents = captureEvents {
            return captureEvents.contains(eventType)
        }
        
        return true
    }
    
}
