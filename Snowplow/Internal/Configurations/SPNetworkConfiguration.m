//
//  SPNetworkConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPNetworkConfiguration.h"

@implementation SPNetworkConfiguration

- (instancetype)initWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPRequestOptions)method {
    if (self = [super init]) {
        self.endpoint = endpoint;
        self.protocol = protocol;
        self.method = method;
        
        self.customPostPath = nil;
        self.timeout = 5;
    }
    return self;
}

@end
