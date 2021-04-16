//
//  ConfigurationProvider.h
//  Snowplow
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRemoteConfiguration.h"
#import "SPFetchedConfigurationBundle.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnFetchCallback)(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle);

/*!
 This class fetch a configuration from a remote source otherwise it provides a cached configuration.
 It can manage multiple sources and multiple caches.
 */
@interface SPConfigurationProvider : NSObject

- (instancetype)initWithRemoteConfiguration:(SPRemoteConfiguration *)remoteConfiguration;

- (void)retrieveConfiguration:(OnFetchCallback)onFetchCallback;

@end

NS_ASSUME_NONNULL_END
