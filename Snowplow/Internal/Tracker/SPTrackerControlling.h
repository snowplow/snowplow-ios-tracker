//
//  SPTrackerControlling.h
//  Snowplow
//
//  Created by Alex Benini on 02/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTrackerConfiguration.h"
#import "SPNetworkConfiguration.h"

#import "SPSessionControlling.h"
#import "SPEmitterControlling.h"
#import "SPNetworkControlling.h"
#import "SPGDPRControlling.h"
#import "SPGlobalContextsControlling.h"

#import "SPSelfDescribingJson.h"
#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerControlling)
@protocol SPTrackerControlling <SPTrackerConfigurationProtocol>

@property (readonly, nonatomic, readonly) NSString *version;
@property (readonly, nonatomic, readonly) BOOL isTracking;

@property (readonly, nonatomic, nullable) id<SPSessionControlling> session;
@property (readonly, nonatomic) id<SPNetworkControlling> network;
@property (readonly, nonatomic) id<SPEmitterControlling> emitter;
@property (readonly, nonatomic) id<SPGDPRControlling> gdpr;
@property (readonly, nonatomic) id<SPGlobalContextsControlling> globalContexts;

- (void)trackSelfDescribingEvent:(SPSelfDescribingJson *)event;
- (void)track:(SPEvent *)event;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
