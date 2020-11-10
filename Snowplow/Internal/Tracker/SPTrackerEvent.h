//
//  SPTrackerEvent.h
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPTrackerEvent : NSObject <SPInspectableEvent>

@property (nonatomic) NSDictionary<NSString *, NSObject *> *payload;
@property (nonatomic) NSString *schema;
@property (nonatomic) NSString *eventName;
@property (nonatomic) NSUUID *eventId;
@property (nonatomic) long long timestamp;
@property (nonatomic) NSNumber *trueTimestamp;
@property (nonatomic) NSMutableArray<SPSelfDescribingJson *> *contexts;

@property (nonatomic) BOOL isPrimitive;
@property (nonatomic) BOOL isService;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithEvent:(SPEvent *)event;

@end

NS_ASSUME_NONNULL_END
