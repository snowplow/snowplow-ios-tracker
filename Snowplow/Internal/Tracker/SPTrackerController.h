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

#import "SPSubjectController.h"
#import "SPSessionController.h"
#import "SPEmitterController.h"
#import "SPNetworkController.h"
#import "SPGDPRController.h"
#import "SPGlobalContextsController.h"

#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerController)
@protocol SPTrackerController <SPTrackerConfigurationProtocol>

/** Version of the tracker. */
@property (readonly, nonatomic) NSString *version;
/**
 * Whether the tracker is running and able to collect/send events.
 * See `pause()` and `resume()`.
 */
@property (readonly, nonatomic) BOOL isTracking;
/**
 * Namespace of the tracker.
 * It is used to identify the tracker among multiple trackers running in the same app.
 */
@property (readonly, nonatomic) NSString *namespace;

/**
 * SubjectController.
 * @apiNote Don't retain the reference. It may change on tracker reconfiguration.
 */
@property (readonly, nonatomic, nullable) id<SPSubjectController> subject;
/**
 * SessionController.
 * @apiNote Don't retain the reference. It may change on tracker reconfiguration.
 */
@property (readonly, nonatomic, nullable) id<SPSessionController> session;
/**
 * NetworkController.
 * @apiNote Don't retain the reference. It may change on tracker reconfiguration.
 */
@property (readonly, nonatomic, nullable) id<SPNetworkController> network;
/**
 * EmitterController.
 * @apiNote Don't retain the reference. It may change on tracker reconfiguration.
 */
@property (readonly, nonatomic) id<SPEmitterController> emitter;
/**
 * GdprController.
 * @apiNote Don't retain the reference. It may change on tracker reconfiguration.
 */
@property (readonly, nonatomic) id<SPGDPRController> gdpr;
/**
 * GlobalContextsController.
 * @apiNote Don't retain the reference. It may change on tracker reconfiguration.
 */
@property (readonly, nonatomic) id<SPGlobalContextsController> globalContexts;

/**
 * Track the event.
 * The tracker will take care to process and send the event assigning `event_id` and `device_timestamp`.
 * @param event The event to track.
 */
- (void)track:(SPEvent *)event;
/**
 * Pause the tracker.
 * The tracker will stop any new activity tracking but it will continue to send remaining events
 * already tracked but not sent yet.
 * Calling a track method will not have any effect and event tracked will be lost.
 */
- (void)pause;
/**
 * Resume the tracker.
 * The tracker will start tracking again.
 */
- (void)resume;

@end

NS_ASSUME_NONNULL_END
