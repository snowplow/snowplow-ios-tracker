//
//  SPFetchedConfigurationBundle.m
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

#import "SPFetchedConfigurationBundle.h"
#import "NSDictionary+SP_TypeMethods.h"
#import "SPLogger.h"

@implementation SPFetchedConfigurationBundle

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSObject *> *)dictionary {
    if (self = [super init]) {
        self.schema = [dictionary sp_stringForKey:@"$schema" defaultValue:nil];
        if (!self.schema) {
            SPLogDebug(@"Error assigning: schema");
            return nil;
        }
        NSNumber *number = [dictionary sp_numberForKey:SP_STR_PROP(configurationVersion) defaultValue:nil];
        if (!number) {
            SPLogDebug(@"Error assigning: configurationVersion");
            return nil;
        }
        self.configurationVersion = number.integerValue;
        self.configurationBundle = [dictionary sp_arrayForKey:SP_STR_PROP(configurationBundle) itemClass:SPConfigurationBundle.class defaultValue:nil];
        if (!self.configurationBundle) {
            SPLogDebug(@"Error assigning: configurationBundle");
            return nil;
        }
    }
    return self;
}

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPFetchedConfigurationBundle *copy;
    copy.schema = self.schema;
    copy.configurationVersion = self.configurationVersion;
    copy.configurationBundle = [self.configurationBundle copyWithZone:zone];
    return copy;
}

// MARK: - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.schema forKey:SP_STR_PROP(schema)];
    [coder encodeInteger:self.configurationVersion forKey:SP_STR_PROP(configurationVersion)];
    [coder encodeObject:self.configurationBundle forKey:SP_STR_PROP(configurationBundle)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.schema = [coder decodeObjectForKey:SP_STR_PROP(schema)];
        self.configurationVersion = [coder decodeIntegerForKey:SP_STR_PROP(configurationVersion)];
        self.configurationBundle = [coder decodeObjectForKey:SP_STR_PROP(configurationBundle)];
    }
    return self;
}

@end
