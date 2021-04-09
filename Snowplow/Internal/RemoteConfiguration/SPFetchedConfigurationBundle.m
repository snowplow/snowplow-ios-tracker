//
//  SPFetchedConfigurationBundle.m
//  Snowplow
//
//  Created by Alex Benini on 13/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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
