//
//  SNOWContext.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/4/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SNOWContext.h"
#import "SPPayload.h"
#import "SNOWContextGenerator.h"
#import "SNOWSchemaRuleset.h"
#import "SPSelfDescribingJson.h"
#import "SNOWContextFilter.h"

@implementation SNOWContext : NSObject

- (id) init {
    return [self initWithRuleset:nil andFilter:nil andCollection:@[]];
}

- (id)copyWithZone:(NSZone *)zone
{
    SNOWContext * copy = [[[self class] alloc] initWithRuleset:_ruleset
                                                     andFilter:_filter
                                                 andCollection:_contexts];
    [copy setTag:_tag];
    return copy;
}

- (void) addContextsFromArray:(NSArray *)array {
    if (_generators == nil) {
        _generators = [[NSMutableArray alloc] init];
    }
    if (_contexts == nil) {
        _contexts = [[NSMutableArray alloc] init];
    }
    for (id object in array) {
        if ([object isKindOfClass:[SPSelfDescribingJson class]]) {
            [_contexts addObject:[object copy]];
        } else if ([object isKindOfClass:[SNOWContextGenerator class]]) {
            [_generators addObject:[object copy]];
        } else {
            // log invalid object in collection
        }
    }
}

- (id) initWithFilter:(SNOWContextFilter *)filter andGenerator:(SNOWContextGenerator *)generator {
    NSArray<SNOWContextGenerator *> * generators = [[NSArray alloc] initWithObjects:generator, nil];
    return [self initWithFilter:filter andCollection:generators];
}

- (id) initWithFilter:(SNOWContextFilter *)filter andContext:(SPSelfDescribingJson *)context {
    NSArray<SPSelfDescribingJson *> * contexts = [[NSArray alloc] initWithObjects:context, nil];
    return [self initWithFilter:filter andCollection:contexts];
}

- (id) initWithFilter:(SNOWContextFilter *)filter andCollection:(NSArray *)collection {
    return [self initWithRuleset:nil andFilter:filter andCollection:collection];
}

- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andGenerator:(SNOWContextGenerator *)generator {
    NSArray<SNOWContextGenerator *> * generators = [[NSArray alloc] initWithObjects:generator, nil];
    return [self initWithRuleset:ruleset andCollection:generators];
}

- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andContext:(SPSelfDescribingJson *)context {
    NSArray<SPSelfDescribingJson *> * contexts = [[NSArray alloc] initWithObjects:context, nil];
    return [self initWithRuleset:ruleset andCollection:contexts];
}

- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andCollection:(NSArray *)collection {
    return [self initWithRuleset:ruleset andFilter:nil andCollection:collection];
}

- (id) initWithGenerator:(SNOWContextGenerator *)generator {
    NSArray<SNOWContextGenerator *> * generators = [[NSArray alloc] initWithObjects:generator, nil];
    return [self initWithCollection:generators];
}

- (id) initWithContext:(SPSelfDescribingJson *)context {
    NSArray<SPSelfDescribingJson *> * contexts = [[NSArray alloc] initWithObjects:context, nil];
    return [self initWithCollection:contexts];
}

- (id) initWithCollection:(NSArray *)collection {
    return [self initWithRuleset:nil andFilter:nil andCollection:collection];
}

- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andFilter:(SNOWContextFilter *)filter andCollection:(NSArray *)collection {
    if (self = [super init]) {
        _ruleset = ruleset;
        _filter = filter;
        _tag = @"";
        [self addContextsFromArray:collection];
        return self;
    }
    return nil;
}

- (NSArray<SPSelfDescribingJson *> *) evaluateWithPayload:(SPPayload *)payload
                                             andEventType:(NSString *)type
                                             andSchemaURI:(NSString *)schema {
    
    NSMutableArray<SPSelfDescribingJson *> * results = [[NSMutableArray<SPSelfDescribingJson *> alloc] init];
    if (self.filter) {
        NSLog(@"reached filter evaluation");
        if (![self.filter evaluateWithPayload:payload andEventType:type andSchemaURI:schema]) {
            return nil;
        }
    } else if (self.ruleset) {
        NSLog(@"reached ruleset evaluation");
        if (![self.ruleset evaluateWithSchemaURI:schema]) {
            return nil;
        }
    }
    for (id context in self.contexts) {
        [results addObject:context];
    }
    for (SNOWContextGenerator * generator in self.generators) {
        NSLog(@"adding from generator");
        NSArray<SPSelfDescribingJson *> * generated = [generator evaluateWithPayload:payload andEventType:type andSchemaURI:schema];
        if (generated) {
            [results addObjectsFromArray:generated];
        }
    }
    return results;
}

@end
