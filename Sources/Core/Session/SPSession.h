//
//  SPSession.h
//  Snowplow
//
//  Copyright (c) 2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Joshua Beemster
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPTracker.h"
#import "SPSessionState.h"

NS_SWIFT_NAME(Session)
@interface SPSession : NSObject

/// Callback to be called when the session is updated
@property OnSessionStateUpdate onSessionStateUpdate;

/// Returns the current session state
@property (readonly) SPSessionState *state;

/**
 * Initializes a newly allocated SnowplowSession
 * @param foregroundTimeout the session timeout while it is in the foreground
 * @param backgroundTimeout the session timeout while it is in the background
 * @return a SnowplowSession
 */
- (instancetype)initWithForegroundTimeout:(NSInteger)foregroundTimeout
                     andBackgroundTimeout:(NSInteger)backgroundTimeout;

/**
 * Initializes a newly allocated SnowplowSession
 * @param foregroundTimeout the session timeout while it is in the foreground
 * @param backgroundTimeout the session timeout while it is in the background
 * @param tracker reference to the associated tracker of the session
 * @return a SnowplowSession
 */
- (instancetype)initWithForegroundTimeout:(NSInteger)foregroundTimeout
                     andBackgroundTimeout:(NSInteger)backgroundTimeout
                               andTracker:(SPTracker *)tracker;

/**
 * Starts the recurring timer check for sessions
 */
- (void) startChecker;

/**
 * Stops the recurring timer check for sessions
 */
- (void) stopChecker;

/// Expires the current session and starts a new one
- (void)startNewSession;

/**
 * Sets a new foreground timeout in milliseconds
 */
- (void) setForegroundTimeout:(NSInteger)foregroundTimeout;

/**
 * Sets a new background timeout in milliseconds
 */
- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout;

/**
 * Returns the currently set Foreground Timeout in milliseconds
 */
- (NSInteger) getForegroundTimeout;

/**
 * Returns the currently set Background Timeout in milliseconds
 */
- (NSInteger) getBackgroundTimeout;

/**
 * Returns the current tracker associated with the session
 */
- (SPTracker *) getTracker;

/**
 * Returns the session dictionary
 * @param firstEventId The potential first event id of the session
 * @param firstEventTimestamp Device created timestamp of the first event of the session
 * @param userAnonymisation Whether to anonymise user identifiers
 * @return a SnowplowPayload containing the session dictionary
 */
- (NSDictionary *) getSessionDictWithEventId:(NSString *)firstEventId
                              eventTimestamp:(long long)firstEventTimestamp
                           userAnonymisation:(BOOL)userAnonymisation;

/**
 * Returns the foreground index count
 * @return a count of foregrounds
 */
- (NSInteger) getForegroundIndex;

/**
 * Returns the background index count
 * @return a count of backgrounds
 */
- (NSInteger) getBackgroundIndex;

/**
 * Returns whether the application is in the background or foreground
 * @return boolean truth of application location
 */
- (BOOL) getInBackground;

/**
 * Returns the session's userId
 * @return the session's userId
 */
- (NSString*) getUserId;

@end
