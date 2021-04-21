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
        self.formatVersion = [dictionary sp_stringForKey:SP_STR_PROP(formatVersion) defaultValue:nil];
        if (!self.formatVersion) {
            SPLogDebug(@"Error assigning: formatVersion");
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
    copy.formatVersion = self.formatVersion;
    copy.configurationVersion = self.configurationVersion;
    copy.configurationBundle = [self.configurationBundle copyWithZone:zone];
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.formatVersion forKey:SP_STR_PROP(formatVersion)];
    [coder encodeInteger:self.configurationVersion forKey:SP_STR_PROP(configurationVersion)];
    [coder encodeObject:self.configurationBundle forKey:SP_STR_PROP(configurationBundle)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.formatVersion = [coder decodeObjectForKey:SP_STR_PROP(formatVersion)];
        self.configurationVersion = [coder decodeIntegerForKey:SP_STR_PROP(configurationVersion)];
        self.configurationBundle = [coder decodeObjectForKey:SP_STR_PROP(configurationBundle)];
    }
    return self;
}

@end
