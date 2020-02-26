//
//  SPBackground.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPBackground.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"

@implementation SPBackground {
    NSNumber * _index;
}

+ (instancetype) build:(void(^)(id<SPBackgroundBuilder>builder))buildBlock {
    SPBackground* event = [SPBackground new];
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

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:_index forKey:kSPBackgroundIndex];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPBackgroundSchema andData:event];
}

@end
