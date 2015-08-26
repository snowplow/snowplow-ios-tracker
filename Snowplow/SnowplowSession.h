//
//  SnowplowSession.h
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SnowplowPayload;

@interface SnowplowSession : NSObject

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
 * Returns the session dictionary
 * @return a SnowplowPayload containing the session dictionary
 */
- (SnowplowPayload *) getSessionDict;

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
