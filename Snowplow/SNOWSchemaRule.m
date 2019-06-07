//
//  SNOWSchemaRule.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/6/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SNOWSchemaRule.h"

@implementation SNOWSchemaRule

- (id) copyWithZone:(NSZone *)zone {
    SNOWSchemaRule * copy = [[[self class] alloc] init];
    [copy setRule:_rule];
    [copy setRuleParts:[[NSMutableArray alloc] initWithArray:_ruleParts copyItems:YES]];
    return copy;
}

- (id) init {
    return [self initWithRule:@""];
}

- (id) initWithRule:(NSString *)rule {
    if (self = [super init]) {
        _rule = rule;
        if ([@"" isEqualToString:rule]) {
            _ruleParts = @[];
            return self;
        } else {
            _ruleParts = [self getPartsFromRule:rule];
        }
        if (_ruleParts == nil) {
            return nil;
        } else {
            return self;
        }
    }
    return nil;
}

- (NSArray<NSString *> *) getPartsFromRule:(NSString *)rule {
    NSError * error = NULL;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:@"^iglu:((?:(?:[a-zA-Z0-9-_]+|\\*)\\.)+(?:[a-zA-Z0-9-_]+|\\*))\\/([a-zA-Z0-9-_\\.]+|\\*)\\/([a-zA-Z0-9-_\\.]+|\\*)\\/([1-9][0-9]*|\\*)-(0|[1-9][0-9]*|\\*)-(0|[1-9][0-9]*|\\*)$" options:0 error:&error];
    NSTextCheckingResult * match = [regex firstMatchInString:_rule
                                                     options:0
                                                       range:NSMakeRange(0, [rule length])];
    if (match == nil) {
        NSLog(@"No matches");
        return nil;
    } else {
        NSMutableArray * ruleParts = [[NSMutableArray alloc] initWithCapacity:6];
        for (int i = 1; i < [match numberOfRanges]; i++) {
            NSString * part = [rule substringWithRange:[match rangeAtIndex:i]];
            [ruleParts setObject:[part copy] atIndexedSubscript:i-1];
        }
        // reject rule if vendor format isn't valid
        if (![self validateVendor:[ruleParts objectAtIndex:0]]) {
            NSLog(@"Vendor not valid");
            return nil;
        }
        return ruleParts;
    }
}

- (bool) matchRule:(NSString *)rulePart withURI:(NSString *)uriPart {
    if (rulePart != nil && uriPart != nil) {
        NSLog(@"rule: %@ uri: %@", rulePart, uriPart);
        if ([rulePart isEqualToString:@"*"]) {
            return true;
        } else if ([uriPart isEqualToString:rulePart]) {
            return true;
        }
    }
    return false;
}

- (NSArray *) getVendorParts:(NSString *)vendor {
    NSArray * components = [vendor componentsSeparatedByString:@"."];
    return components;
}

+ (NSArray *) getPartsFromURI:(NSString *)uri {
    NSError * error = NULL;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:@"^iglu:((?:(?:[a-zA-Z0-9-_]+)\\.)+(?:[a-zA-Z0-9-_]+))\\/([a-zA-Z0-9-_]+)\\/([a-zA-Z0-9-_]+)\\/([1-9][0-9]*)\\-(0|[1-9][0-9]*)\\-(0|[1-9][0-9]*)$" options:0 error:&error];
    NSTextCheckingResult * match = [regex firstMatchInString:uri
                                                     options:0
                                                       range:NSMakeRange(0, [uri length])];
    NSMutableArray * uriParts = [[NSMutableArray alloc] initWithCapacity:6];
    for (int i = 1; i < [match numberOfRanges]; i++) {
        NSString * part = [uri substringWithRange:[match rangeAtIndex:i]];
        [uriParts setObject:[part copy] atIndexedSubscript:i-1];
    }
    return uriParts;
}

- (bool) validateVendor:(NSString *)vendor {
    // the components array will be generated like this from vendor:
    // "com.acme.marketing" => ["com", "acme", "marketing"]
    NSArray * components = [vendor componentsSeparatedByString:@"."];
    // check that vendor doesn't begin or end with period
    // e.g. ".snowplowanalytics.snowplow." => ["", "snowplowanalytics", "snowplow", ""]
    if (components.count > 1 &&
        ([@"" isEqualToString:[components objectAtIndex:0]] ||
         [@"" isEqualToString:[components objectAtIndex:components.count-1]])) {
        return false;
    }
    // reject vendors with criteria that are too broad & don't make sense, i.e. "*.*.marketing"
    if ([@"*" isEqualToString:[components objectAtIndex:0]] || [@"*" isEqualToString:[components objectAtIndex:1]]) {
        return false;
    }
    // now validate the remaining parts, vendors should follow matching that never breaks trailing specificity
    // in other words, once we use an asterisk, we must continue using asterisks for parts or stop
    // e.g. "com.acme.marketing.*.*" is allowed, but "com.acme.*.marketing.*" or "com.acme.*.marketing" is forbidden
    if (components.count <= 2) return true;
    // trailingComponents are the remaining parts after the first two
    NSArray * trailingComponents = [components subarrayWithRange:NSMakeRange(2, components.count-2)];
    bool asterisk = false;
    for (id part in trailingComponents) {
        if ([@"*" isEqualToString:part]) { // mark when we've found a wildcard
            asterisk = true;
        } else if (asterisk) { // invalid when alpha parts come after wildcard
            return false;
        }
    }
    return true;
}

- (bool) matchVendorRuleToParts:(NSArray *)uriParts {
    NSLog(@"got past first count");
    NSArray * ruleParts = [self getVendorParts:[_ruleParts objectAtIndex:0]];
    if ([uriParts count] != [ruleParts count]) return false;
    NSLog(@"URI count: %@ Rule count: %@", uriParts, ruleParts);
    NSUInteger index = 0;
    for (id rulePart in ruleParts) {
        if (([@"*" isEqualToString:rulePart] && [uriParts objectAtIndex:index] == nil) ||
            (![[uriParts objectAtIndex:index] isEqualToString:rulePart] && ![@"*" isEqualToString:rulePart])) {
            return false;
        }
        index++;
    }
    return true;
}

- (bool) match:(NSString *)uri {
    NSLog(@"entered match for uri: %@", uri);
    NSArray * uriParts = [SNOWSchemaRule getPartsFromURI:uri];
    NSLog(@"uri parts: %@", uriParts);
    [self setRuleParts:[self getPartsFromRule:_rule]];
    if (_ruleParts == nil || _ruleParts.count != 6) {
        NSLog(@"Failed ruleparts");
        return false;
    }
    NSLog(@"vendor match");
    // get vendor parts from below!!!
    if (![self matchVendorRuleToParts:[self getVendorParts:[uriParts objectAtIndex:0]]]) {
        NSLog(@"failed vendor rule to parts");
        return false;
    }
    NSUInteger index = 1;
    NSLog(@"rule match");
    for (NSString * rulePart in [_ruleParts subarrayWithRange:NSMakeRange(1, _ruleParts.count-1)]) {
        if (![self matchRule:rulePart withURI:[uriParts objectAtIndex:index]]) {
            NSLog(@"failed other rule part");
            return false;
        }
        index++;
    }
    return true;
}

- (BOOL) isEqual: (id)other {
    return [other isKindOfClass:[SNOWSchemaRule class]] && [_rule isEqualToString:[(SNOWSchemaRule *)other rule]];
}

- (NSUInteger) hash {
    return [_rule hash];
}

@end
