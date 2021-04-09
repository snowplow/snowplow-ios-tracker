//
//  SPFetchedConfigurationBundle.h
//  Snowplow
//
//  Created by Alex Benini on 13/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPConfigurationBundle.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPFetchedConfigurationBundle : SPConfiguration

@property (nonatomic, nonnull) NSString *formatVersion;
@property (nonatomic) NSInteger configurationVersion;
@property (nonatomic, nonnull) NSArray<SPConfigurationBundle *> *configurationBundle;

@end

NS_ASSUME_NONNULL_END
