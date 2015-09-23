//
//  SPSession.h
//  Snowplow
//
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@interface SPSession : NSObject

/**
 * Initializes a newly allocated SnowplowSession
 * @return a SnowplowSession
 */
- (id) init;

/**
 * Initializes a newly allocated SnowplowSession
 * @param foregroundTimeout the session timeout while it is in the foreground
 * @param backgroundTimeout the session timeout while it is in the background
 * @param checkInterval how often to query for if the session has timed out
 * @return a SnowplowSession
 */
- (id) initWithForegroundTimeout:(NSInteger)foregroundTimeout andBackgroundTimeout:(NSInteger)backgroundTimeout andCheckInterval:(NSInteger)checkInterval;

/**
 * Starts the recurring timer check for sessions
 */
- (void) startChecker;

/**
 * Stops the recurring timer check for sessions
 */
- (void) stopChecker;

/**
 * Sets a new foreground timeout
 */
- (void) setForegroundTimeout:(NSInteger)foregroundTimeout;

/**
 * Sets a new background timeout
 */
- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout;

/**
 * Sets a new check interval and restarts the timer
 */
- (void) setCheckInterval:(NSInteger)checkInterval;

/**
 * Returns the currently set Foreground Timeout
 */
- (NSInteger) getForegroundTimeout;

/**
 * Returns the currently set Background Timeout
 */
- (NSInteger) getBackgroundTimeout;

/**
 * Returns the currently set Check Interval
 */
- (NSInteger) getCheckInterval;

/**
 * Returns the session dictionary
 * @param firstEventId The potential first event id of the session
 * @return a SnowplowPayload containing the session dictionary
 */
- (NSMutableDictionary *) getSessionDictWithEventId:(NSString *)firstEventId;

/**
 * Returns the current session index count
 * @return a count of sessions
 */
- (NSInteger) getSessionIndex;

/**
 * Returns whether the application is in the background or foreground
 * @return boolean truth of application location
 */
- (BOOL) getInBackground;

@end
