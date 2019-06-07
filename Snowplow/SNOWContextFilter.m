//
//  SNOWContextFilter.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/4/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SNOWContextFilter.h"
#import "SPPayload.h"

@implementation SNOWContextFilter : NSObject

- (id) copyWithZone:(NSZone *)zone {
    SNOWContextFilter * copy = [[[self class] alloc] init];
    [copy setFilter:self.filter];
    return copy;
}

- (id) init {
    return [self initWithFilter:^bool(SPPayload *event, NSString *eventType, NSString *eventSchema) {
        return YES;
    }];
}

- (id) initWithFilter:(filterBlock)filter {
    if (self = [super init]) {
        _filter = filter;
        return self;
    }
    return nil;
}

- (bool) evaluateWithPayload:(SPPayload *)payload andEventType:(NSString *)type andSchemaURI:(NSString *)schema{
    bool passes = false;
    @try {
        passes = _filter(payload, type, schema);
    }
    @catch (NSException *exception) {
        NSLog(@"Caught an exception");
        // We'll just silently ignore the exception.
    }
    return passes;
}

@end
