//
//  SPConfigurationBundle.m
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

#import "SPConfigurationBundle.h"
#import "NSDictionary+SP_TypeMethods.h"
#import "SPLogger.h"

@interface SPConfigurationBundle ()
@property (nonatomic, nonnull) NSString *namespace;
@end

@implementation SPConfigurationBundle

- (instancetype)initWithNamespace:(NSString *)namespace networkConfiguration:(SPNetworkConfiguration *)networkConfiguration {
    if (self = [super init]) {
        self.namespace = namespace;
        self.networkConfiguration = networkConfiguration;
    }
    return self;
}

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
