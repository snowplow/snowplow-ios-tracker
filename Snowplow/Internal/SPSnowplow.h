//
//  SPSnowplow.h
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
#import "SPTrackerController.h"
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Snowplow)
@interface SPSnowplow : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

+ (id<SPTrackerController>)createTrackerWithNamespace:(NSString *)namespace endpoint:(NSString *)endpoint method:(SPHttpMethod)method NS_SWIFT_NAME(createTracker(namespace:endpoint:method:));

+ (id<SPTrackerController>)createTrackerWithNamespace:(NSString *)namespace network:(SPNetworkConfiguration *)networkConfiguration NS_SWIFT_NAME(createTracker(namespace:network:));

+ (id<SPTrackerController>)createTrackerWithNamespace:(NSString *)namespace network:(SPNetworkConfiguration *)networkConfiguration configurations:(NSArray<SPConfiguration *> *)configurations NS_SWIFT_NAME(createTracker(namespace:network:configurations:));

+ (nullable id<SPTrackerController>)defaultTracker;

+ (BOOL)setTrackerAsDefault:(id<SPTrackerController>)trackerController NS_SWIFT_NAME(setAsDefault(tracker:));

+ (BOOL)removeTracker:(id<SPTrackerController>)trackerController NS_SWIFT_NAME(remove(tracker:));

+ (void)removeAllTrackers NS_SWIFT_NAME(removeAllTrackers());

+ (NSArray<NSString *> *)instancedTrackerNamespaces;

@end

NS_ASSUME_NONNULL_END
