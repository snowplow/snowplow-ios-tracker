//
//  SPSessionController.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPSessionConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionController)
@protocol SPSessionController <SPSessionConfigurationProtocol>

/**
 * The session index.
 * An increasing number which helps to order the sequence of sessions.
 */
@property (readonly) NSInteger sessionIndex;
/**
 * The session identifier.
 * A unique identifier which is used to identify the session.
 */
@property (readonly) NSString *sessionId;
/**
 * The session user identifier.
 * It identifies this app installation and it doesn't change for the life of the app.
 * It will change only when the app is uninstalled and installed again.
 * An app update doesn't change the value.
 */
@property (readonly) NSString *userId;

/**
 * Whether the app is currently in background state or in foreground state.
 */
@property (readonly) BOOL isInBackground;
/**
 * Count the number of background transitions in the current session.
 */
@property (readonly) NSInteger backgroundIndex;
/**
 * Count the number of foreground transitions in the current session.
 */
@property (readonly) NSInteger foregroundIndex;

/**
 * Pause the session tracking.
 * Meanwhile the session is paused it can't expire and can't be updated.
 */
- (void)pause;
/**
 * Resume the session tracking.
 */
- (void)resume;
/**
 * Expire the current session also if the timeout is not triggered.
 */
- (void)startNewSession;

@end

NS_ASSUME_NONNULL_END
