//
//  SPConfigurationCache.h
//  Snowplow
//
//  Created by Alex Benini on 15/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPFetchedConfigurationBundle.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPConfigurationCache : NSObject

- (nullable SPFetchedConfigurationBundle *)readCache;
- (void)writeCache:(SPFetchedConfigurationBundle *)configuration;
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
