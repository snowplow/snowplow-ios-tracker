//
//  SPNetworkConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPNetworkConnection.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(NetworkConfiguration)
@interface SPNetworkConfiguration : SPConfiguration

@property () NSString *endpoint;
@property () SPRequestOptions method;
@property () SPProtocol protocol;

@property (nullable) NSString *customPostPath;
@property () NSInteger timeout;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPRequestOptions)method;

@end

NS_ASSUME_NONNULL_END
