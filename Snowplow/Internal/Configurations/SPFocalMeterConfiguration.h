//
//  SPFocalMeterConfiguration.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPGlobalContext.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(FocalMeterConfigurationProtocol)
@protocol SPFocalMeterConfigurationProtocol

@property (nonatomic, nullable) NSString *kantarEndpoint;

@end

/**
 This configuration tells the tracker to send requests with the user ID in session context entity
 to a Kantar endpoint used with Focal Meter.
 The request is made when the first event with a new user ID is tracked.
 The requests are only made if session context is enabled (default).
 */
NS_SWIFT_NAME(FocalMeterConfiguration)
@interface SPFocalMeterConfiguration : SPConfiguration <SPFocalMeterConfigurationProtocol>

/**
 Creates a configuration for the Kantar Focal Meter.
 @param endpoint URL of the Kantar endpoint to send the requests to
 */
- (instancetype)initWithKantarEndpoint:(NSString *)endpoint
NS_SWIFT_NAME(init(kantarEndpoint:));

/**
 URL of the Kantar endpoint to send the requests to
 */
SP_BUILDER_DECLARE_NULLABLE(NSString *, kantarEndpoint)

@end

NS_ASSUME_NONNULL_END
