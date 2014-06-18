//
//  SnowplowTracker.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#include "SnowplowPayload.h"

@interface SnowplowEventStore : NSObject

- (id) init;

- (void) setAppId:(NSString *)appId;

- (NSString *) getAppId;

- (BOOL) createTableWithBundleId:(NSString *)bundleId;

- (BOOL) insertEvent:(SnowplowPayload *)payload;

- (void) getTable;

- (BOOL) getEventWithId:(NSNumber*) id;

- (NSDictionary *) getAllEvents;

@end
