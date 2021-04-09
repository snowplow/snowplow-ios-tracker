//
//  SPRemoteConfiguration.h
//  Snowplow
//
//  Created by Alex Benini.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPNetworkConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents the configuration for fetching configurations from a remote source.
 */
NS_SWIFT_NAME(RemoteConfiguration)
@interface SPRemoteConfiguration : SPConfiguration

/**
 * URL (without schema/protocol) used to send events to the collector.
 */
@property (nonatomic, nullable, readonly) NSString *endpoint;

/**
 * Method used to send events to the collector.
 */
@property (nonatomic, readonly) SPHttpMethod method;

/**
 * @param endpoint URL of the remote configuration.
 *                 The URL can include the schema/protocol (e.g.: `http://remote-config-url.xyz`).
 *                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
 *                 automatically selected.
 * @param method The method used to send the requests (GET or POST).
 */
- (instancetype)initWithEndpoint:(NSString *)endpoint method:(SPHttpMethod)method;

@end

NS_ASSUME_NONNULL_END
