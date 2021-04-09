//
//  SPConfigurationFetcher.h
//  Snowplow
//
//  Created by Alex Benini on 04/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRemoteConfiguration.h"
#import "SPConfigurationProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPConfigurationFetcher : NSObject

- (instancetype)initWithRemoteSource:(SPRemoteConfiguration *)remoteConfiguration onFetchCallback:(OnFetchCallback)onFetchCallback;

@end

NS_ASSUME_NONNULL_END
