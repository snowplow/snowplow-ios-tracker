//
//  SPNetworkConfigurationUpdate.m
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPNetworkConfigurationUpdate.h"

@implementation SPNetworkConfigurationUpdate

- (NSString *)endpoint {
    return [self.sourceConfig endpoint];
}

- (SPHttpMethod)method {
    return [self.sourceConfig method];
}

- (SPProtocol)protocol {
    return [self.sourceConfig protocol];
}

- (id<SPNetworkConnection>)networkConnection {
    return [self.sourceConfig networkConnection];
}

// SP_DIRTY_GETTER replacement as NetworkConfigurationUpdate doesn't extend NetworkConfiguration like the others updater classes.
- (NSString *)customPostPath { return self.customPostPathUpdated ? _customPostPath : self.sourceConfig.customPostPath; }
- (NSDictionary *)requestHeaders { return self.requestHeadersUpdated ? _requestHeaders : self.sourceConfig.requestHeaders; }

@end
