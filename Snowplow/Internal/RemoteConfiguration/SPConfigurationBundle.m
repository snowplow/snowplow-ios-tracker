//
//  SPConfigurationBundle.m
//  Snowplow
//
//  Created by Alex Benini on 13/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPConfigurationBundle.h"
#import "NSDictionary+SP_TypeMethods.h"
#import "SPLogger.h"

@implementation SPConfigurationBundle

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSObject *> *)dictionary {
    if (self = [super init]) {
        self.namespace = [dictionary sp_stringForKey:SP_STR_PROP(namespace) defaultValue:nil];
        if (!self.namespace) {
            SPLogDebug(@"Error assigning: namespace");
            return nil;
        }
        self.networkConfiguration = (SPNetworkConfiguration *)[dictionary sp_configurationForKey:SP_STR_PROP(networkConfiguration) configurationClass:SPNetworkConfiguration.class defaultValue:nil];
        self.trackerConfiguration = (SPTrackerConfiguration *)[dictionary sp_configurationForKey:SP_STR_PROP(trackerConfiguration) configurationClass:SPTrackerConfiguration.class defaultValue:nil];
        self.subjectConfiguration = (SPSubjectConfiguration *)[dictionary sp_configurationForKey:SP_STR_PROP(subjectConfiguration) configurationClass:SPSubjectConfiguration.class defaultValue:nil];
        self.sessionConfiguration = (SPSessionConfiguration *)[dictionary sp_configurationForKey:SP_STR_PROP(sessionConfiguration) configurationClass:SPSessionConfiguration.class defaultValue:nil];
    }
    return self;
}

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPConfigurationBundle *copy;
    copy.namespace = self.namespace;
    copy.networkConfiguration = [self.networkConfiguration copyWithZone:zone];
    copy.trackerConfiguration = [self.trackerConfiguration copyWithZone:zone];
    copy.subjectConfiguration = [self.subjectConfiguration copyWithZone:zone];
    copy.sessionConfiguration = [self.sessionConfiguration copyWithZone:zone];
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.namespace forKey:SP_STR_PROP(namespace)];
    [coder encodeObject:self.networkConfiguration forKey:SP_STR_PROP(networkConfiguration)];
    [coder encodeObject:self.trackerConfiguration forKey:SP_STR_PROP(trackerConfiguration)];
    [coder encodeObject:self.subjectConfiguration forKey:SP_STR_PROP(subjectConfiguration)];
    [coder encodeObject:self.sessionConfiguration forKey:SP_STR_PROP(sessionConfiguration)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.namespace = [coder decodeObjectForKey:SP_STR_PROP(namespace)];
        self.networkConfiguration = [coder decodeObjectForKey:SP_STR_PROP(networkConfiguration)];
        self.trackerConfiguration = [coder decodeObjectForKey:SP_STR_PROP(trackerConfiguration)];
        self.subjectConfiguration = [coder decodeObjectForKey:SP_STR_PROP(subjectConfiguration)];
        self.sessionConfiguration = [coder decodeObjectForKey:SP_STR_PROP(sessionConfiguration)];
    }
    return self;
}

@end
