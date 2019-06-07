//
//  SNOWContextGenerator.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/5/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SNOWContextGenerator.h"
#import "SPSelfDescribingJson.h"
#import "SPPayload.h"

@implementation SNOWContextGenerator : NSObject

- (id) copyWithZone:(NSZone *)zone {
    SNOWContextGenerator * copy = [[[self class] alloc] init];
    [copy setBlock:[_block copy]];
    return copy;
}

- (id) init {
    return [self initWithBlock:^NSArray<SPSelfDescribingJson *> *(SPPayload *event, NSString *eventType, NSString *eventSchema) {
        return [NSArray array];
    }];
}

- (id) initWithBlock:(SNOWGeneratorBlock)block {
    if (self = [super init]) {
        _block = block;
        return self;
    }
    return nil;
}

- (NSArray<SPSelfDescribingJson *> *) validateResults:(NSArray<SPSelfDescribingJson *> *)results {
    NSMutableArray<SPSelfDescribingJson *> * validated = [[NSMutableArray<SPSelfDescribingJson *> alloc] init];
    if (results == nil) {
        return @[];
    }
    for (id result in results) {
        if ([result isKindOfClass:[SPSelfDescribingJson class]]) {
            [validated addObject:result];
        }
    }
    return validated;
}

- (NSArray<SPSelfDescribingJson *> *) evaluateWithPayload:(SPPayload *)payload andEventType:(NSString *)type andSchemaURI:(NSString *)schema {
    NSArray<SPSelfDescribingJson *> * blockOutput;
    @try {
        blockOutput = _block(payload, type, schema);
    }
    @catch (NSException *exception) {
        NSLog(@"Caught an exception");
        // We'll just silently ignore the exception.
    }
    NSArray<SPSelfDescribingJson *> * results = [self validateResults:blockOutput];
    if (results.count > 0) {
        NSLog(@"returning results");
        return results;
    } else {
        NSLog(@"no results");
        return nil;
    }
}

@end
