//
//  SPSubject.h
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
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPPayload;

@interface SPSubject : NSObject

/**
 * Initializes a newly allocated SnowplowSubject object.
 * @return a new SnowplowSubject
 */
- (id) init;

/**
 * Creates a subject which also creates all Platform specific pairs.
 * @param whether to create platform dictionary
 * @return a new SnowplowSubject
 */
- (id) initWithPlatformContext:(BOOL)platformContext;

/**
 * Gets all standard dictionary pairs to decorate the event with.
 * @return a SnowplowPayload with all standard pairs
 */
- (SPPayload *) getStandardDict;

/**
 * Gets all platform dictionary pairs to decorate event with.
 * @return a SnowplowPayload with all platform specific pairs
 */
- (SPPayload *) getPlatformDict;

/**
 * Sets the standard pairs for the Subject, called automatically on object creation.
 */
- (void) setStandardDict;

/**
 * Optional mobile/desktop context, if selected will be automatically populated on object creation.
 */
- (void) setPlatformDict;

@end
