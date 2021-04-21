//
//  SPConfigurationBundle.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.
//
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPConfiguration.h"
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPSubjectConfiguration.h"
#import "SPSessionConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents the default configuration applied in place of the remote configuration.
 */
NS_SWIFT_NAME(ConfigurationBundle)
@interface SPConfigurationBundle : SPConfiguration

@property (nonatomic, nonnull, readonly) NSString *namespace;
@property (nonatomic, nullable) SPNetworkConfiguration *networkConfiguration;
@property (nonatomic, nullable) SPTrackerConfiguration *trackerConfiguration;
@property (nonatomic, nullable) SPSubjectConfiguration *subjectConfiguration;
@property (nonatomic, nullable) SPSessionConfiguration *sessionConfiguration;

@property (nonatomic, nonnull, readonly) NSArray<SPConfiguration *> *configurations;

- (instancetype)initWithNamespace:(NSString *)namespace networkConfiguration:(SPNetworkConfiguration *)networkConfiguration;

@end

NS_ASSUME_NONNULL_END
