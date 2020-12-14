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

NS_SWIFT_NAME(NetworkConfigurationProtocol)
@protocol SPNetworkConfigurationProtocol

@property () NSString *endpoint;
@property () SPRequestOptions method;
@property () SPProtocol protocol;

@property (nullable) NSString *customPostPath;
// TODO: add -> @property () NSInteger timeout;

@end


NS_SWIFT_NAME(NetworkConfiguration)
@interface SPNetworkConfiguration : SPConfiguration <SPNetworkConfigurationProtocol>

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPRequestOptions)method;

SP_BUILDER_DECLARE_NULLABLE(NSString *, customPostPath)

@end

NS_ASSUME_NONNULL_END
