//
//  SPEventBase.h
//  Snowplow
//
//  Copyright (c) 2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPSelfDescribingJson.h"
#import "SPTrackerConstants.h"

@class SPPayload;
@class SPTracker;

/// An enum for screen types.
typedef NS_ENUM(NSInteger, SPScreenType) {
    // sourced from `View Controller Catalog for iOS`
    SPScreenTypeDefault,
    SPScreenTypeNavigation,
    SPScreenTypeTabBar,
    SPScreenTypePageView,
    SPScreenTypeSplitView,
    SPScreenTypePopoverPresentation,
    SPScreenTypeModal,
    SPScreenTypeCombined
} NS_SWIFT_NAME(ScreenType);

NSString * _Nullable stringWithSPScreenType(SPScreenType screenType);

NS_ASSUME_NONNULL_BEGIN

/// The inspectable properties of the event used to generate contexts.
NS_SWIFT_NAME(InspectableEvent)
@protocol SPInspectableEvent <NSObject>

/// The schema of the event
@property (nonatomic, readonly, nullable) NSString *schema;
/// The name of the event
@property (nonatomic, readonly, nullable) NSString *eventName;
/// The payload of the event
@property (nonatomic, readonly) NSDictionary<NSString *, NSObject *> *payload;

@end


/// This protocol defines basic functionality needed to build all events
NS_SWIFT_NAME(EventBuilder)
@protocol SPEventBuilder <NSObject>

/*!
 @brief Set the optional timestamp of the event.
 @param timestamp The timestamp of the event in seconds (epoch time)
 */
- (void)setTrueTimestamp:(NSDate *)timestamp;

/*!
 @brief Set the contexts attached to the event.
 @param contexts An array of contexts (should be self-describing JSONs).
 */
- (void) setContexts:(NSMutableArray *)contexts;

@end


/// This class has the basic functionality needed to represent all events
NS_SWIFT_NAME(Event)
@interface SPEvent : NSObject

/*! The user event timestamp in milliseconds (epoch time). */
@property (nonatomic, nullable) NSDate *trueTimestamp;

/*! The contexts attached to the event. */
@property (nonatomic) NSMutableArray<SPSelfDescribingJson *> *contexts;

/*! The payload of the event. */
@property (nonatomic, readonly) NSDictionary<NSString *, NSObject *> *payload;

SP_BUILDER_DECLARE_NULLABLE(NSDate *, trueTimestamp)
SP_BUILDER_DECLARE(NSMutableArray<SPSelfDescribingJson *> *, contexts)

/*!
 @brief Get the copy of the context list associated with the event.
 @deprecated Use `contexts` property instead.
*/
- (NSMutableArray *) getContexts __deprecated_msg("Use `contexts` property instead.");

/**
 * Hook method called just before the event processing in order to execute special operations.
 * @note Internal use only - Don't use in production, it can change without notice.
 */
- (void)beginProcessingWithTracker:(SPTracker *)tracker;

/**
 * Hook method called just after the event processing in order to execute special operations.
 * @note Internal use only - Don't use in production, it can change without notice.
 */
- (void)endProcessingWithTracker:(SPTracker *)tracker;
@end

/*!
 @interface SPSelfDescribingAbstract
 @brief The properties for all the self-describing events.
 */
NS_SWIFT_NAME(SelfDescribingAbstract)
@interface SPSelfDescribingAbstract : SPEvent

/*! The schema of the event. */
@property (nonatomic, readonly) NSString *schema;

@end

/*!
 @interface SPPrimitiveAbstract
 @brief The properties for all the self-describing events.
 */
NS_SWIFT_NAME(PrimitiveAbstract)
@interface SPPrimitiveAbstract : SPEvent

/*! The name of the event. */
@property (nonatomic, readonly) NSString *name;

@end

NS_ASSUME_NONNULL_END
