//
//  SPGlobalContextsConfiguration.m
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPGlobalContextsConfiguration.h"

@implementation SPGlobalContextsConfiguration

@synthesize contextGenerators;

- (instancetype)init {
    if (self = [super init]) {
        self.contextGenerators = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)addWithTag:(nonnull NSString *)tag contextGenerator:(nonnull SPGlobalContext *)generator {
    if ([self.contextGenerators objectForKey:tag]) {
        return NO;
    }
    [self.contextGenerators setObject:generator forKey:tag];
    return YES;
}

- (nullable SPGlobalContext *)removeWithTag:(nonnull NSString *)tag {
    SPGlobalContext *toDelete = [self.contextGenerators objectForKey:tag];
    if (toDelete) {
        [self.contextGenerators removeObjectForKey:tag];
    }
    return toDelete;
}

// MARK: - Builder

SP_BUILDER_METHOD(SP_ESCAPE(NSMutableDictionary<NSString *, SPGlobalContext *> *), contextGenerators)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPGlobalContextsConfiguration *copy = [[SPGlobalContextsConfiguration allocWithZone:zone] init];
    copy.contextGenerators = self.contextGenerators;
    return copy;
}

// MARK: - NSCoding (No coding possible as we can't encode and decode the contextGenerators)

@end
