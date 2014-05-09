//
//  Snowplow.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-08.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import "Snowplow.h"

@implementation Snowplow

- (id) initWithURLString:(NSString *) url {
    self = [super init];
    if(self) {
        self.requestHandler = [[SnowplowRequest alloc] initWithURLRequest:[[NSURL alloc] initWithString:url] withHTTPMethod:@"POST"];
    }
    
    return self;
}

// TODO: Remove
- (void) sendEvent:(NSDictionary *) data {
    [self.requestHandler sendRequest:data];
}

@end
