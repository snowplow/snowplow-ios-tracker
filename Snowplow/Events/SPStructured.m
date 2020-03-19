//
//  SPStructured.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPStructured.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@implementation SPStructured {
    NSString * _category;
    NSString * _action;
    NSString * _label;
    NSString * _property;
    NSNumber * _value;
}

+ (instancetype) build:(void(^)(id<SPStructuredBuilder>builder))buildBlock {
    SPStructured* event = [SPStructured new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category cannot be nil or empty."];
    [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setCategory:(NSString *)category {
    _category = category;
}

- (void) setAction:(NSString *)action {
    _action = action;
}

- (void) setLabel:(NSString *)label {
    _label = label;
}

- (void) setProperty:(NSString *)property {
    _property = property;
}

- (void) setValue:(double)value {
    _value = [NSNumber numberWithDouble:value];
}

// --- Public Methods

- (NSString *)name {
    return kSPEventStructured;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_category forKey:kSPStuctCategory];
    [payload setValue:_action forKey:kSPStuctAction];
    [payload setValue:_label forKey:kSPStuctLabel];
    [payload setValue:_property forKey:kSPStuctProperty];
    if (_value) [payload setObject:[NSString stringWithFormat:@"%.17g", [_value doubleValue]] forKey:kSPStuctValue];
    return payload;
}

- (SPPayload *) getPayload {
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:kSPEventStructured forKey:kSPEvent];
    [payload addValueToPayload:_category forKey:kSPStuctCategory];
    [payload addValueToPayload:_action forKey:kSPStuctAction];
    [payload addValueToPayload:_label forKey:kSPStuctLabel];
    [payload addValueToPayload:_property forKey:kSPStuctProperty];
    [payload addValueToPayload:[NSString stringWithFormat:@"%.17g", [_value doubleValue]] forKey:kSPStuctValue];
    [self addDefaultParamsToPayload:payload];
    return payload;
}

@end
