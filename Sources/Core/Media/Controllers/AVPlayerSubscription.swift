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

#if !os(watchOS)
import Foundation
import AVKit

/**
 Internal class that subscribes to events from an AVPlayer video player instance and tracks media events.
 */
class AVPlayerSubscription {

    /// Notification types to subscribe to
    private let notificationNames: [Notification.Name] = [
        .AVPlayerItemPlaybackStalled,
        .AVPlayerItemDidPlayToEndTime,
        .AVPlayerItemFailedToPlayToEndTime,
    ]

    /// Media player to track
    private var player: AVPlayer
    private var lastPauseTime: CMTime?
    private var mediaTracking: MediaTracking

    init(player: AVPlayer, mediaTracking: MediaTracking) {
        self.mediaTracking = mediaTracking
        self.player = player

        // notifications for playback events
        let notificationCenter = NotificationCenter.default
        notificationNames.forEach {
            notificationCenter.addObserver(self,
                                           selector: #selector(handleNotification(_:)),
                                           name: $0,
                                           object: nil)
        }

        // add a playback rate observer to find out when the user plays or pauses the videos
        rateObserver = player.observe(\.rate, options: [.old, .new]) { [weak self] player, change in
            InternalQueue.async {
                guard let oldRate = change.oldValue else { return }
                guard let newRate = change.newValue else { return }
                
                if oldRate != 0 && newRate == 0 { // paused
                    self?.lastPauseTime = player.currentTime()
                    self?.track(MediaPauseEvent())
                } else if oldRate == 0 && newRate != 0 { // started playing
                    // when the current time diverges significantly, i.e. more than 1 second, from what it was when last paused, track a seek event
                    if let lastPauseTime = self?.lastPauseTime {
                        if abs(player.currentTime().seconds - lastPauseTime.seconds) > 1 {
                            self?.track(MediaSeekEndEvent())
                        }
                    }
                    self?.lastPauseTime = nil
                    self?.track(MediaPlayEvent())
                }
            }
        }

        addPositionObserver()
    }

    /// Detaches the subscription handler from the player instance.
    ///
    /// It's recommended to call this method before the player instance disappears (likely in the onDisappear callback of your View) to gracefully close all the observers.
    func unsubscribe() {
        notificationNames.forEach { name in
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
        playbackBufferObserver = nil
        rateObserver = nil
        removePositionObserver()
    }

    // MARK: private members

    private func track(_ event: Event) {
        mediaTracking.track(event, player: MediaPlayerEntity(player: player))
    }
    
    private func update() {
        mediaTracking.update(player: MediaPlayerEntity(player: player))
    }

    /// Handles notifications from the notification center subscriptions
    @objc private func handleNotification(_ notification: Notification) {
        InternalQueue.async {
            switch notification.name {
            case .AVPlayerItemPlaybackStalled:
                self.track(MediaBufferStartEvent())
            case .AVPlayerItemDidPlayToEndTime:
                self.track(MediaEndEvent())
            case .AVPlayerItemFailedToPlayToEndTime:
                self.track(MediaErrorEvent(errorDescription: self.player.error?.localizedDescription))
            default:
                return
            }
        }
    }

    /// The playback rate observer is used to get notified of changes in the playback rate which indicate the video being paused or played
    private var rateObserverKey: UInt8 = 0
    private var rateObserver: NSKeyValueObservation? {
        get {
            return objc_getAssociatedObject(self, &rateObserverKey) as? NSKeyValueObservation
        }
        set {
            rateObserver.flatMap { $0.invalidate() }
            objc_setAssociatedObject(self, &rateObserverKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    private var playbackBufferObserverKey: UInt8 = 0
    private var playbackBufferObserver: NSKeyValueObservation? {
        get {
            return objc_getAssociatedObject(self, &playbackBufferObserverKey) as? NSKeyValueObservation
        }
        set {
            playbackBufferObserver.flatMap { $0.invalidate() }
            objc_setAssociatedObject(self, &playbackBufferObserverKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var positionObserverToken: Any?

    func addPositionObserver() {
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        positionObserverToken =
            player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
                [weak self] _ in
                InternalQueue.async {
                    self?.update()
                }
        }
    }

    func removePositionObserver() {
        if let positionObserverToken = positionObserverToken {
            player.removeTimeObserver(positionObserverToken)
            self.positionObserverToken = nil
        }
    }
}

#endif
