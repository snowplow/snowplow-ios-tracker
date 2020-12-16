//
//  SPNetworkControlling.h
//  Snowplow
//
//  Created by Alex Benini on 14/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNetworkConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(NetworkControlling)
@protocol SPNetworkControlling

@property (nonatomic, nullable) NSString *endpoint;
@property (nonatomic) SPRequestOptions method;
@property (nonatomic) SPProtocol protocol;

@property (nonatomic, nullable) NSString *customPostPath;

@end

NS_ASSUME_NONNULL_END
