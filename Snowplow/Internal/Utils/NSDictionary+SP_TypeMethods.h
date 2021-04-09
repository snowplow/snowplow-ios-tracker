//
//  NSDictionary+SP_TypeMethods.h
//  Snowplow
//
//  Created by Alex Benini on 14/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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
