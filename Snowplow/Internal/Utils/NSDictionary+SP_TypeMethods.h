//
//  NSDictionary+SP_TypeMethods.h
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

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (SP_TypeMethods)

- (nullable NSString *)sp_stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;
- (nullable NSNumber *)sp_numberForKey:(NSString *)key defaultValue:(nullable NSNumber *)defaultValue;
- (BOOL)sp_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (nullable NSDictionary *)sp_dictionaryForKey:(NSString *)key defaultValue:(nullable NSDictionary *)defaultValue;
- (nullable NSArray *)sp_arrayForKey:(NSString *)key itemClass:(nullable Class)itemClass defaultValue:(nullable NSArray *)defaultValue;
- (nullable NSObject *)sp_objectForKey:(NSString *)key objectClass:(nullable Class)objectClass defaultValue:(nullable NSArray *)defaultValue;
- (nullable SPConfiguration *)sp_configurationForKey:(NSString *)key configurationClass:(Class)configurationClass defaultValue:(nullable SPConfiguration *)defaultValue;

@end

NS_ASSUME_NONNULL_END
