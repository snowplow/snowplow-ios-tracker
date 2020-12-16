//
//  SPUnstructured.m
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

#import "SPUnstructured.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SPUnstructured {
    SPSelfDescribingJson * _eventData;
}

+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock {
    SPUnstructured* event = [SPUnstructured new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_eventData != nil) withMessage:@"EventData cannot be nil."];
    [SPUtilities checkArgument:[NSJSONSerialization isValidJSONObject:_eventData.data] withMessage:@"EventData has to be JSON serializable."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setEventData:(SPSelfDescribingJson *)eventData {
    _eventData = eventData;
}

// --- Public Methods

- (NSString *)schema {
    return _eventData.schema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSObject *data = [_eventData data];
    if ([data isKindOfClass:[NSDictionary<NSString *, NSObject *> class]]) {
        return (NSDictionary<NSString *, NSObject *> *)data;
    }
    return nil;
}

- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding {
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:kSPEventUnstructured forKey:kSPEvent];

    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:kSPUnstructSchema
                                                        andSelfDescribingJson:_eventData];

    [payload addDictionaryToPayload:[sdj getAsDictionary]
                 base64Encoded:encoding
               typeWhenEncoded:kSPUnstructuredEncoded
            typeWhenNotEncoded:kSPUnstructured];
    return [self addDefaultParamsToPayload:payload];
}

@end
