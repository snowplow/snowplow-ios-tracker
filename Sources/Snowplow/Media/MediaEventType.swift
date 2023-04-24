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

/// Type of media player event
@objc(SPMediaEventType)
public enum MediaEventType: Int {
    // Controlling the playback

    /** Media player event fired when the media tracking is successfully attached to the player and can track events. */
    case ready
    /** Media player event sent when the player changes state to playing from previously being paused. */
    case play
    /** Media player event sent when the user pauses the playback. */
    case pause
    /** Media player event sent when playback stops when end of the media is reached or because no further data is available. */
    case end
    /** Media player event sent when a seek operation begins. */
    case seekStart
    /** Media player event sent when a seek operation completes. */
    case seekEnd

    // Changes in playback settings

    /** Media player event sent when the playback rate has changed. */
    case playbackRateChange
    /** Media player event sent when the volume has changed. */
    case volumeChange
    /** Media player event fired immediately after the browser switches into or out of full-screen mode. */
    case fullscreenChange
    /** Media player event fired immediately after the browser switches into or out of picture-in-picture mode. */
    case pictureInPictureChange

    // Tracking playback progress

    /** Media player event fired periodicaly during main content playback, regardless of other API events that have been sent. */
    case ping
    /** Media player event fired when a percentage boundary set in options.boundaries is reached */
    case percentProgress

    // Ad events

    /** Media player event that signals the start of an ad break. */
    case adBreakStart
    /** Media player event that signals the end of an ad break. */
    case adBreakEnd
    /** Media player event that signals the start of an ad. */
    case adStart
    /** Media player event fired when a quartile of ad is reached after continuous ad playback at normal speed. */
    case adFirstQuartile
    /** Media player event fired when a midpoint of ad is reached after continuous ad playback at normal speed. */
    case adMidpoint
    /** Media player event fired when a quartile of ad is reached after continuous ad playback at normal speed. */
    case adThirdQuartile
    /** Media player event that signals the ad creative was played to the end at normal speed. */
    case adComplete
    /** Media player event fired when the user activated a skip control to skip the ad creative. */
    case adSkip
    /** Media player event fired when the user clicked on the ad. */
    case adClick
    /** Media player event fired when the user clicked the pause control and stopped the ad creative. */
    case adPause
    /** Media player event fired when the user resumed playing the ad creative after it had been stopped or paused. */
    case adResume

    // Data quality events

    /** Media player event fired when the player goes into the buffering state and begins to buffer content. */
    case bufferStart
    /** Media player event fired when the the player finishes buffering content and resumes playback. */
    case bufferEnd
    /** Media player event tracked when the video playback quality changes automatically. */
    case qualityChange
    /** Media player event tracked when the video playback quality changes as a result of user interaction (choosing a different quality setting). */
    case userUpdateQuality
    /** Media player event tracked when the resource could not be loaded due to an error.  */
    case error
}

