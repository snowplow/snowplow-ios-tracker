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
#import "SPSelfDescribingJson.h"
#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerControlling)
@protocol SPTrackerControlling <SPTrackerConfigurationProtocol>

@property (readonly, nonatomic, readonly) NSString *version;
@property (readonly, nonatomic, readonly) BOOL isTracking;

@property (readonly, nonatomic, nullable) id<SPSessionControlling> session;

- (void)trackSelfDescribingEvent:(SPSelfDescribingJson *)event;
- (void)track:(SPEvent *)event;
- (void)pause;
- (void)resume;

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration NS_SWIFT_NAME(setup(network:tracker:));

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations  NS_SWIFT_NAME(setup(network:tracker:configurations:));

@end

NS_ASSUME_NONNULL_END
