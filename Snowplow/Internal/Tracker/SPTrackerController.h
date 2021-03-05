//
//  SPTrackerController.h
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

#import <Foundation/Foundation.h>
#import "SPTrackerConfiguration.h"
#import "SPNetworkConfiguration.h"

#import "SPSessionController.h"
#import "SPEmitterController.h"
#import "SPNetworkController.h"
#import "SPGDPRController.h"
#import "SPGlobalContextsController.h"

#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerController)
@protocol SPTrackerController <SPTrackerConfigurationProtocol>

@property (readonly, nonatomic) NSString *version;
@property (readonly, nonatomic) BOOL isTracking;

@property (readonly, nonatomic, nullable) id<SPSessionController> session;
@property (readonly, nonatomic, nullable) id<SPNetworkController> network;
@property (readonly, nonatomic) id<SPEmitterController> emitter;
@property (readonly, nonatomic) id<SPGDPRController> gdpr;
@property (readonly, nonatomic) id<SPGlobalContextsController> globalContexts;

- (void)track:(SPEvent *)event;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
