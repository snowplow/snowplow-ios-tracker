//
//  SPGlobalContextsConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 04/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
