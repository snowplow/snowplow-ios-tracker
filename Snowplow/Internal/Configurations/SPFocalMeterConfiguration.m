//
//  SPFocalMeterConfiguration.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPFocalMeterConfiguration.h"

@implementation SPFocalMeterConfiguration

@synthesize kantarEndpoint;

- (instancetype)initWithKantarEndpoint:(NSString *)kantarEndpoint
{
    if (self = [super init]) {
        self.kantarEndpoint = kantarEndpoint;
    }
    return self;
}

// MARK: - Builder

SP_BUILDER_METHOD(NSString *, kantarEndpoint)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPFocalMeterConfiguration *copy = [[SPFocalMeterConfiguration allocWithZone:zone] initWithKantarEndpoint:kantarEndpoint];
    return copy;
}

// MARK: - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.kantarEndpoint forKey:SP_STR_PROP(kantarEndpoint)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.kantarEndpoint = [coder decodeObjectForKey:SP_STR_PROP(kantarEndpoint)];
    }
    return self;
}

@end
