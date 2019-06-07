//
//  SNOWSchemaRuleset.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/4/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SNOWSchemaRuleset.h"
#import "SNOWSchemaRule.h"

@implementation SNOWSchemaRuleset : NSObject

- (id) copyWithZone:(NSZone *)zone {
    SNOWSchemaRuleset * copy = [[SNOWSchemaRuleset alloc] init];
    [copy setAllow:[[NSMutableArray alloc] initWithArray:_allow copyItems:YES]];
    [copy setDeny:[[NSMutableArray alloc] initWithArray:_deny copyItems:YES]];
    return copy;
}

- (id) init {
    return [self initWithAllowList:@[] andDenyList:@[]];
}

- (id) initWithDenyList:(NSArray<NSString *> *)deny {
    return [self initWithAllowList:@[] andDenyList:deny];
}

- (id) initWithAllowList:(NSArray<NSString *> *)allow {
    return [self initWithAllowList:allow andDenyList:@[]];
}

- (id) initWithAllowList:(NSArray<NSString *> *)allow andDenyList:(NSArray<NSString *> *)deny {
    if (self = [super init]) {
        _allow = [[NSMutableArray alloc] init];
        _deny = [[NSMutableArray alloc] init];
        for (id rule in deny) {
            NSLog(@"initializing deny rule");
            SNOWSchemaRule * schemaRule = [[SNOWSchemaRule alloc] initWithRule:rule];
            if (schemaRule != nil) {
                NSLog(@"adding deny rule");
                [_deny addObject:schemaRule];
            }
        }
        for (id rule in allow) {
            NSLog(@"initializing allow rule");
            SNOWSchemaRule * schemaRule = [[SNOWSchemaRule alloc] initWithRule:rule];
            if (schemaRule != nil) {
                NSLog(@"adding allow rule");
                [_allow addObject:schemaRule];
                NSLog(@"%@", _allow);
            }
        }
        return self;
    }
    return nil;
}

- (bool) evaluateWithSchemaURI:(NSString *)uri {
    bool isAllowed = false;
    for (SNOWSchemaRule * rule in _deny) {
        NSLog(@"deny rule match evaluation");
        if ([rule match:uri]) {
            return false;
        }
    }
    for (SNOWSchemaRule * rule in _allow) {
        NSLog(@"allow rule match evaluation");
        if ([rule match:uri]) {
            NSLog(@"allow matched");
            isAllowed = true;
        }
    }
    NSLog(@"here's the rules:");
    NSLog(@"allow: %@", _allow);
    NSLog(@"deny: %@", _deny);
    NSLog(@"isAllowed: %@", isAllowed ? @"YES" : @"NO");
    return isAllowed;
}

@end
