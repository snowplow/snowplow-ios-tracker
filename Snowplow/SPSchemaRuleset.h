//
//  SNOWSchemaRuleset.h
//  Snowplow-iOS
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPSchemaRule.h"
#import "SPGlobalContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSchemaRuleset : NSObject <NSCopying>

@property (readonly, copy) NSArray<NSString *> *denied;
@property (readonly, copy) NSArray<NSString *> *allowed;

@property (nonatomic, readonly) SPFilterBlock filterBlock;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

/*!
 Generate a set of rules based on allowed and denied event schemas.
 @param allowed Rules of allowed schemas.
 */
+ (SPSchemaRuleset *)rulesetWithAllowedList:(NSArray<NSString *> *)allowed;
/*!
 Generate a set of rules based on allowed and denied event schemas.
 @param denied Rules of denied schemas.
 */
+ (SPSchemaRuleset *)rulesetWithDeniedList:(NSArray<NSString *> *)denied;
/*!
 Generate a set of rules based on allowed and denied event schemas.
 @param allowed Rules of allowed schemas.
 @param denied Rules of denied schemas.
 */
+ (SPSchemaRuleset *)rulesetWithAllowedList:(NSArray<NSString *> *)allowed andDeniedList:(NSArray<NSString *> *)denied;

/*!
 Weather the `uri` match the stored rules.
 @param uri URI to check.
 @return Weather the uri is allowed.
 */
- (BOOL)matchWithUri:(NSString *)uri;

@end

NS_ASSUME_NONNULL_END
