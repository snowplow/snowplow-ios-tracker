//
//  SPForeground.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPForeground.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"

@implementation SPForeground {
    NSNumber * _index;
}

+ (instancetype) build:(void(^)(id<SPForegroundBuilder>builder))buildBlock {
    SPForeground* event = [SPForeground new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_index != nil) withMessage:@"Index cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setIndex:(NSNumber *)index {
    _index = index;
}

// --- Public Methods

- (NSString *)schema {
    return kSPForegroundSchema;
}

- (NSDictionary *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_index forKey:kSPForegroundIndex];
    return payload;
}

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:_index forKey:kSPForegroundIndex];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPForegroundSchema andData:event];
}

@end
