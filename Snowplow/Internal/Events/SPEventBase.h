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

@class SPPayload;
@class SPTracker;

/*!
 @brief An enum for screen types.
 */
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

NSString * stringWithSPScreenType(SPScreenType screenType);

/*!
 @protocol SPInspectableEvent
 @brief The inspectable properties of the event used to generate contexts.
 */
NS_SWIFT_NAME(InspectableEvent)
@protocol SPInspectableEvent <NSObject>

/*! The schema of the event. */
@property (nonatomic, readonly) NSString *schema;
/*! The name of the event. */
@property (nonatomic, readonly) NSString *eventName;
/*! The payload of the event. */
@property (nonatomic, readonly) NSDictionary<NSString *, NSObject *> *payload;

@end

/*!
 @protocol SPEventBuilder
 @brief The base protocol for all event builders.

 This protocol defines basic functionality needed to build all events.
 */
NS_SWIFT_NAME(EventBuilder)
@protocol SPEventBuilder <NSObject>

/*!
 @brief Set the optional timestamp of the event.
 @param timestamp The timestamp of the event in seconds (epoch time)
 */
- (void)setTrueTimestamp:(NSNumber *)timestamp;

/*!
 @brief Set the contexts attached to the event.
 @param contexts An array of contexts (should be self-describing JSONs).
 */
- (void) setContexts:(NSMutableArray *)contexts;

@end

/*!
 @class SPEvent
 @brief The base object for all events.

 This class has the basic functionality needed to represent all events.
 */
NS_SWIFT_NAME(Event)
@interface SPEvent : NSObject <SPEventBuilder>

/*! The user event timestamp in milliseconds (epoch time). */
@property (nonatomic, readwrite) NSNumber *trueTimestamp;

/*! The contexts attached to the event. */
@property (nonatomic, readwrite, retain) NSMutableArray *contexts;

/*! The payload of the event. */
@property (nonatomic, readonly) NSDictionary<NSString *, NSObject *> *payload;

- (void) basePreconditions;

/*!
 @brief Get the copy of the context list associated with the event.
*/
- (NSMutableArray *) getContexts;

/*!
 @brief Get the user timestamp of the event in seconds (epoch time) if it has been set.
*/
- (NSNumber *)getTrueTimestamp;

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
 @interface SPSelfDescribing
 @brief The properties for all the self-describing events.
 */
NS_SWIFT_NAME(SelfDescribing)
@interface SPSelfDescribing : SPEvent

/*! The schema of the event. */
@property (nonatomic, readonly) NSString *schema;

@end

/*!
 @interface SPPrimitive
 @brief The properties for all the self-describing events.
 */
NS_SWIFT_NAME(Primitive)
@interface SPPrimitive : SPEvent

/*! The name of the event. */
@property (nonatomic, readonly) NSString *name;

@end
