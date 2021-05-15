//
//  SPNetworkConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTrackerConstants.h"
#import "SPNetworkConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPNetworkConfigurationUpdate : NSObject

@property (nonatomic, nullable) SPNetworkConfiguration *sourceConfig;

@property (nonatomic, nullable) NSString *customPostPath;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *requestHeaders;

- (nullable NSString *)endpoint;
- (SPHttpMethod)method;
- (SPProtocol)protocol;
- (nullable id<SPNetworkConnection>)networkConnection;

SP_DIRTYFLAG(customPostPath)
SP_DIRTYFLAG(requestHeaders)

@end

NS_ASSUME_NONNULL_END
