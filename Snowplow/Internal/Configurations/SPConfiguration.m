//
//  SPConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 27/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPConfiguration.h"

@implementation SPConfiguration

- (nonnull instancetype)copyWithZone:(nullable NSZone *)zone {
    return [[SPConfiguration allocWithZone:zone] init];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    return [[SPConfiguration alloc] init];
}

@end
