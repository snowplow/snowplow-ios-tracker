//
//  SNOWSchemaRule.m
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

#import "SPSchemaRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSchemaRule ()

@property (nonatomic, copy, readwrite) NSString *rule;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *ruleParts;

@end

@implementation SPSchemaRule

static NSString * const kRulePattern = @"^iglu:((?:(?:[a-zA-Z0-9-_]+|\\*)\\.)+(?:[a-zA-Z0-9-_]+|\\*))\\/([a-zA-Z0-9-_\\.]+|\\*)\\/([a-zA-Z0-9-_\\.]+|\\*)\\/([1-9][0-9]*|\\*)-(0|[1-9][0-9]*|\\*)-(0|[1-9][0-9]*|\\*)$";
static NSString * const kUriPattern = @"^iglu:((?:(?:[a-zA-Z0-9-_]+)\\.)+(?:[a-zA-Z0-9-_]+))\\/([a-zA-Z0-9-_]+)\\/([a-zA-Z0-9-_]+)\\/([1-9][0-9]*)\\-(0|[1-9][0-9]*)\\-(0|[1-9][0-9]*)$";

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[SPSchemaRule alloc] initWithRule:self.rule];
}

- (id)initWithRule:(NSString *)rule {
    if (self = [super init]) {
        if (!rule || rule.length == 0) {
            return nil;
        }
        _rule = rule;
        NSArray<NSString *> *parts = [self partsFromUri:rule regexPattern:kRulePattern];
        // reject rule if vendor format isn't valid
        if (!parts.count || ![self validateVendor:parts[0]]) {
            return nil;
        }
        _ruleParts = parts;
    }
    return self;
}

- (BOOL)matchWithUri:(NSString *)uri {
    if (!uri) {
        return NO;
    }
    NSArray<NSString *> *uriParts = [self partsFromUri:uri regexPattern:kUriPattern];
    if (uriParts.count < _ruleParts.count) {
        return NO;
    }
    // Check vendor part
    NSArray<NSString *> *ruleVendor = [_ruleParts[0] componentsSeparatedByString:@"."];
    NSArray<NSString *> *uriVendor = [uriParts[0] componentsSeparatedByString:@"."];
    if (uriVendor.count != ruleVendor.count) {
        return NO;
    }
    NSUInteger index = 0;
    for (NSString *ruleVendorPart in ruleVendor) {
        if (![@"*" isEqualToString:ruleVendorPart] && ![uriVendor[index] isEqualToString:ruleVendorPart]) {
            return NO;
        }
        index++;
    }
    // Check the rest of the rule
    index = 1;
    for (NSString *rulePart in [_ruleParts subarrayWithRange:NSMakeRange(1, _ruleParts.count-1)]) {
        if (![@"*" isEqualToString:rulePart] && ![uriParts[index] isEqualToString:rulePart]) {
            return NO;
        }
        index++;
    }
    return YES;
}

#pragma mark - Private methods

- (nullable NSArray<NSString *> *)partsFromUri:(NSString *)uri regexPattern:(NSString *)pattern {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:uri options:0 range:NSMakeRange(0, uri.length)];
    NSMutableArray *parts = [NSMutableArray arrayWithCapacity:6];
    if (!match) {
        return nil;
    }
    for (int i = 1; i < match.numberOfRanges; i++) {
        if (i > 6) {
            return nil;
        }
        NSString *part = [uri substringWithRange:[match rangeAtIndex:i]];
        [parts setObject:part.copy atIndexedSubscript:i-1];
    }
    return parts;
}

- (BOOL)validateVendor:(NSString *)vendor {
    // the components array will be generated like this from vendor:
    // "com.acme.marketing" => ["com", "acme", "marketing"]
    NSArray<NSString *> *components = [vendor componentsSeparatedByString:@"."];
    // check that vendor doesn't begin or end with period
    // e.g. ".snowplowanalytics.snowplow." => ["", "snowplowanalytics", "snowplow", ""]
    if (components.count > 1 && (!components[0].length || !components[components.count-1].length)) {
        return NO;
    }
    // reject vendors with criteria that are too broad & don't make sense, i.e. "*.*.marketing"
    if ([@"*" isEqualToString:components[0]] || [@"*" isEqualToString:components[1]]) {
        return NO;
    }
    // now validate the remaining parts, vendors should follow matching that never breaks trailing specificity
    // in other words, once we use an asterisk, we must continue using asterisks for parts or stop
    // e.g. "com.acme.marketing.*.*" is allowed, but "com.acme.*.marketing.*" or "com.acme.*.marketing" is forbidden
    if (components.count <= 2) return YES;
    // trailingComponents are the remaining parts after the first two
    NSArray<NSString *> *trailingComponents = [components subarrayWithRange:NSMakeRange(2, components.count-2)];
    BOOL asterisk = NO;
    for (NSString *part in trailingComponents) {
        if ([@"*" isEqualToString:part]) { // mark when we've found a wildcard
            asterisk = true;
        } else if (asterisk) { // invalid when alpha parts come after wildcard
            return NO;
        }
    }
    return YES;
}

#pragma mark - Overriden methods

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:SPSchemaRule.class] && [self.rule isEqualToString:[(SPSchemaRule *)object rule]];
}

- (NSUInteger)hash {
    return [_rule hash];
}

@end

NS_ASSUME_NONNULL_END
