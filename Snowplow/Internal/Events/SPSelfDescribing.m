//
//  SPUnstructured.m
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPSelfDescribing.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SPSelfDescribing {
    SPSelfDescribingJson * _eventData;
    NSString * _schema;
    NSDictionary<NSString *, NSObject *> * _payload;
}

+ (instancetype) build:(void(^)(id<SPSelfDescribingBuilder> builder))buildBlock {
    SPSelfDescribing* event = [SPSelfDescribing new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithEventData:(SPSelfDescribingJson *)eventData {
    if (self = [super init]) {
        [SPUtilities checkArgument:(eventData != nil) withMessage:@"EventData cannot be nil."];
        _schema = eventData.schema;
        [SPUtilities checkArgument:(_schema != nil) withMessage:@"EventData schema cannot be nil."];
        [SPUtilities checkArgument:([eventData.data isKindOfClass:[NSDictionary<NSString *, NSObject *> class]]) withMessage:@"EventData payload is not correctly formatted."];
        _payload = (NSDictionary<NSString *, NSObject *> *) eventData.data;
        [SPUtilities checkArgument:[NSJSONSerialization isValidJSONObject:_payload] withMessage:@"EventData payload has to be JSON serializable."];
        _eventData = eventData;
    }
    return self;
}

- (instancetype)initWithSchema:(NSString *)schema payload:(NSDictionary<NSString *,NSObject *> *)payload {
    if (self = [super init]) {
        _schema = schema;
        [SPUtilities checkArgument:(_schema != nil) withMessage:@"EventData schema cannot be nil."];
        _payload = payload;
        [SPUtilities checkArgument:[NSJSONSerialization isValidJSONObject:_payload] withMessage:@"EventData payload has to be JSON serializable."];
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_eventData != nil) withMessage:@"EventData cannot be nil."];
    [SPUtilities checkArgument:[NSJSONSerialization isValidJSONObject:_eventData.data] withMessage:@"EventData has to be JSON serializable."];
}

// --- Builder Methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void) setEventData:(SPSelfDescribingJson *)eventData {
    _eventData = eventData;
}

#pragma clang diagnostic pop

// --- Public Methods

- (NSString *)schema {
    return _schema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    return _payload;
}

@end
