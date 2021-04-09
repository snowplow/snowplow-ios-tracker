//
//  SPConfigurationBundle.h
//  Snowplow
//
//  Created by Alex Benini on 13/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPConfiguration.h"
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPSubjectConfiguration.h"
#import "SPSessionConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPConfigurationBundle : SPConfiguration

@property (nonatomic, nonnull) NSString *namespace;
@property (nonatomic, nullable) SPNetworkConfiguration *networkConfiguration;
@property (nonatomic, nullable) SPTrackerConfiguration *trackerConfiguration;
@property (nonatomic, nullable) SPSubjectConfiguration *subjectConfiguration;
@property (nonatomic, nullable) SPSessionConfiguration *sessionConfiguration;

@end

NS_ASSUME_NONNULL_END
