//
//  SNOWSchemaRuleset.m
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

#import "SPSchemaRuleset.h"
#import "SPSchemaRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSchemaRuleset ()

@property (nonatomic, copy) NSMutableArray<SPSchemaRule *> *rulesAllowed;
@property (nonatomic, copy) NSMutableArray<SPSchemaRule *> *rulesDenied;

@end

@implementation SPSchemaRuleset: NSObject

- (id)copyWithZone:(nullable NSZone *)zone {
    return [SPSchemaRuleset rulesetWithAllowedList:self.allowed andDeniedList:self.denied];
}

- (instancetype)initWithAllowedList:(NSArray<NSString *> *)allowed andDeniedList:(NSArray<NSString *> *)denied {
    self = [super init];
    if (self) {
        NSMutableArray<SPSchemaRule *> *rulesAllowed = [NSMutableArray array];
        for (NSString *rule in allowed) {
            SPSchemaRule *schemaRule = [[SPSchemaRule alloc] initWithRule:rule];
            if (schemaRule) {
                [rulesAllowed addObject:schemaRule];
            }
        }
        self.rulesAllowed = rulesAllowed;
        NSMutableArray<SPSchemaRule *> *rulesDenied = [NSMutableArray array];
        for (NSString *rule in denied) {
            SPSchemaRule *schemaRule = [[SPSchemaRule alloc] initWithRule:rule];
            if (schemaRule) {
                [rulesDenied addObject:schemaRule];
            }
        }
        self.rulesDenied = rulesDenied;
    }
    return self;
}

+ (SPSchemaRuleset *)rulesetWithAllowedList:(NSArray<NSString *> *)allowed andDeniedList:(NSArray<NSString *> *)denied {
    return [[SPSchemaRuleset alloc] initWithAllowedList:allowed andDeniedList:denied];
}

+ (SPSchemaRuleset *)rulesetWithAllowedList:(NSArray<NSString *> *)allowed {
    return [SPSchemaRuleset rulesetWithAllowedList:allowed andDeniedList:@[]];
}

+ (SPSchemaRuleset *)rulesetWithDeniedList:(NSArray<NSString *> *)denied {
    return [SPSchemaRuleset rulesetWithAllowedList:@[] andDeniedList:denied];
}

- (BOOL)matchWithUri:(NSString *)uri {
    for (SPSchemaRule *rule in self.rulesDenied) {
        if ([rule matchWithUri:uri]) {
            return NO;
        }
    }
    if (!self.rulesAllowed.count) {
        return YES;
    }
    for (SPSchemaRule *rule in self.rulesAllowed) {
        if ([rule matchWithUri:uri]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<NSString *> *)allowed {
    NSMutableArray<NSString *> *result = [NSMutableArray<NSString *> array];
    for (SPSchemaRule *schemaRule in self.rulesAllowed) {
        [result addObject:schemaRule.rule.copy];
    }
    return result;
}

- (NSArray<NSString *> *)denied {
    NSMutableArray<NSString *> *result = [NSMutableArray<NSString *> array];
    for (SPSchemaRule *schemaRule in self.rulesDenied) {
        [result addObject:schemaRule.rule.copy];
    }
    return result;
}

- (SPFilterBlock)filterBlock {
    return ^BOOL(id<SPInspectableEvent> event) {
        return [self matchWithUri:event.schema];
    };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SchemaRuleset:\r\n  allowed:%@\r\n  denied:%@\r\n", self.allowed, self.denied];
}

@end

NS_ASSUME_NONNULL_END
