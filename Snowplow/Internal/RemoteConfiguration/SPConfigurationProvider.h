//
//  ConfigurationProvider.h
//  Snowplow
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRemoteConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnFetchCallback)(NSArray<SPConfiguration*>*_Nonnull);

/*!
 This class fetch a configuration from a remote source otherwise it provides a cached configuration.
 It can manage multiple sources and multiple caches.
 */
@interface SPConfigurationProvider : NSObject

- (void)registerRemoteSource:(SPRemoteConfiguration *)remoteConfig onFetchCallback:(OnFetchCallback)onFetchCallback;

- (NSArray<SPConfiguration *> *)configurationsForNamespace:(NSString *)namespace;

@end

NS_ASSUME_NONNULL_END
