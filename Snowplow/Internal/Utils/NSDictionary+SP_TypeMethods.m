//
//  NSDictionary+SP_TypeMethods.m
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

#import "NSDictionary+SP_TypeMethods.h"

@implementation NSDictionary (SP_TypeMethods)

- (nullable NSString *)sp_stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue {
    NSObject *obj = [self objectForKey:key];
    return [obj isKindOfClass:NSString.class] ? (NSString *)obj : defaultValue;
}

- (nullable NSNumber *)sp_numberForKey:(NSString *)key defaultValue:(nullable NSNumber *)defaultValue {
    NSObject *obj = [self objectForKey:key];
    return [obj isKindOfClass:NSNumber.class] ? (NSNumber *)obj : defaultValue;
}

- (BOOL)sp_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSNumber *num = [self sp_numberForKey:key defaultValue:nil];
    return num ? num.boolValue : defaultValue;
}

- (nullable NSDictionary *)sp_dictionaryForKey:(NSString *)key defaultValue:(nullable NSDictionary *)defaultValue {
    NSObject *obj = [self objectForKey:key];
    return [obj isKindOfClass:NSDictionary.class] ? (NSDictionary *)obj : defaultValue;
}

- (nullable NSArray *)sp_arrayForKey:(NSString *)key itemClass:(nullable Class)itemClass defaultValue:(nullable NSArray *)defaultValue {
    NSObject *obj = [self objectForKey:key];
    if (![obj isKindOfClass:NSArray.class]) {
        return defaultValue;
    }
    NSArray *array = (NSArray *)obj;
    if (!itemClass || [array.firstObject isKindOfClass:itemClass]) {
        return array;
    }
    NSMutableArray *resultArray = [NSMutableArray new];
    if ([itemClass isSubclassOfClass:SPConfiguration.class] && [array.firstObject isKindOfClass:NSDictionary.class]) {
        for (int i = 0; i < array.count; i++) {
            NSDictionary *dictionary = (NSDictionary *)[array objectAtIndex:i];
            SPConfiguration *configuration = [[itemClass alloc] initWithDictionary:dictionary];
            if (!configuration) {
                return defaultValue;
            }
            [resultArray addObject:configuration];
        }
    }
    return resultArray;
}

- (nullable NSObject *)sp_objectForKey:(NSString *)key objectClass:(Class)objectClass defaultValue:(NSObject *)defaultValue {
    NSObject *obj = [self objectForKey:key];
    return (obj && (!objectClass || [obj isKindOfClass:objectClass])) ? obj : defaultValue;
}

- (nullable SPConfiguration *)sp_configurationForKey:(NSString *)key configurationClass:(Class)configurationClass defaultValue:(SPConfiguration *)defaultValue {
    NSObject *obj = [self objectForKey:key];
    if (!obj) {
        return defaultValue;
    }
    if ([obj isKindOfClass:configurationClass]) {
        return (SPConfiguration *)obj;
    }
    SPConfiguration *configuration = nil;
    if ([obj isKindOfClass:NSDictionary.class] && [configurationClass isSubclassOfClass:SPConfiguration.class]) {
        configuration = (SPConfiguration *)[[configurationClass alloc] initWithDictionary:(NSDictionary *)obj];
    }
    return (SPConfiguration *)configuration ?: defaultValue;
}

@end
