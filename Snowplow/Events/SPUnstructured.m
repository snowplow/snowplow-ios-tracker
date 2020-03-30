//
//  SPUnstructured.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
