//
//  SNOWContexts.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 5/31/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SNOWGlobalContexts.h"
#import "SNOWContext.h"
#import "SPPayload.h"
#import "Snowplow.h"

@implementation SNOWGlobalContexts

- (id) init {
    if (self = [super init]) {
        _contexts = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (void) addContext:(SNOWContext *)context {
    [_contexts addObject:context];
}

- (void) addContexts:(NSArray<SNOWContext *> *)contexts {
    for (SNOWContext * context in contexts) {
        [_contexts addObject:context];
    }
}

- (bool) removeContextWithTag:(NSString *)tag {
    NSUInteger index = [self.contexts indexOfObjectPassingTest:^BOOL(SNOWContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tag) {
            return [tag isEqualToString:obj.tag];
        } else {
            return false;
        }
    }];
    if (index == NSNotFound) {
        return false;
    } else {
        [self.contexts removeObjectAtIndex:index];
        return true;
    }
}

- (bool) removeContextsWithTags:(NSArray<NSString *> *)tags {
    bool containsInvalidTag = false;
    for (NSString * tag in tags) {
        if (![self removeContextWithTag:tag]) {
            containsInvalidTag = true;
        }
    }
    return containsInvalidTag;
}

- (void) removeAllContexts {
    [_contexts removeAllObjects];
}

- (NSArray<SPSelfDescribingJson *> *) evaluateWithPayload:(SPPayload *)payload {
    NSString * schema;
    NSString * type;
    [SPPayload inspectEventPayload:payload
                returningEventType:&type
                    andEventSchema:&schema];
    NSMutableArray<SPSelfDescribingJson *> * results = [[NSMutableArray<SPSelfDescribingJson *> alloc] init];
    for (SNOWContext * context in _contexts) {
        NSLog(@"Evaluating a context: %@", context);
        NSArray<SPSelfDescribingJson *> * evaluation = [context evaluateWithPayload:payload andEventType:type andSchemaURI:schema];
        NSLog(@"it's the evaluation");
        if (evaluation && [evaluation count] > 0) {
            [results addObjectsFromArray:evaluation];
        }
    }
    return results;
}

@end
