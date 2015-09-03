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
 * Sets the User ID
 * @param uid as a String
 */
- (void) setUserId:(NSString *)uid;

/**
 * Sets the Screen Resolution
 * @param width as an Int
 * @param height as an Int
 */
- (void) setResolutionWithWidth:(NSInteger)width andHeight:(NSInteger)height;

/**
 * Sets the View Port dimensions
 * @param width as an Int
 * @param height as an Int
 */
- (void) setViewPortWithWidth:(NSInteger)width andHeight:(NSInteger)height;

/**
 * Sets the Color Depth
 * @param depth as an Int
 */
- (void) setColorDepth:(NSInteger)depth;

/**
 * Sets the Timezone
 * @param timezone as a String
 */
- (void) setTimezone:(NSString *)timezone;

/**
 * Sets the Language
 * @param lang the language as a String
 */
- (void) setLanguage:(NSString *)lang;

/**
 * Sets the IP Address
 * @param ip as a String
 */
- (void) setIpAddress:(NSString *)ip;

/**
 * Sets the Useragent
 * @param useragent as a String
 */
- (void) setUseragent:(NSString *)useragent;

/**
 * Sets the Network User ID
 * @param nuid as a String
 */
- (void) setNetworkUserId:(NSString *)nuid;

/**
 * Sets the Domain User ID
 * @param duid as a String
 */
- (void) setDomainUserId:(NSString *)duid;

/**
 * Sets the standard pairs for the Subject, called automatically on object creation.
 */
- (void) setStandardDict;

/**
 * Optional mobile/desktop context, if selected will be automatically populated on object creation.
 */
- (void) setPlatformDict;

@end
