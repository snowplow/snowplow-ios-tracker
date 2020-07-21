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
};

NSString * stringWithSPScreenType(SPScreenType screenType);

/*!
 @protocol SPInspectableEvent
 @brief The inspectable properties of the event used to generate contexts.
 */
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
@protocol SPEventBuilder <NSObject>

/*!
 @brief Set the timestamp of when the event has been processed by the tracker.
 @param timestamp The timestamp of the event in milliseconds (epoch time)
 @deprecated This method is for internal use only and will be removed in the next major version. Use `trueTimestamp` as alternative.
 */
- (void) setTimestamp:(NSNumber *)timestamp __deprecated_msg("The timestamp will be set once the event is processed.");

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

/*!
 @brief Set the UUID associated with the event.
 @param eventId A UUID for the event.
 @deprecated This method is for internal use only and will be removed in the next major version.
 */
- (void) setEventId:(NSString *)eventId __deprecated_msg("The eventId will be set once the event is processed.");
@end

/*!
 @class SPEvent
 @brief The base object for all events.

 This class has the basic functionality needed to represent all events.
 */
@interface SPEvent : NSObject <SPEventBuilder>

/*! The tracker event timestamp in milliseconds (epoch time). */
@property (nonatomic, readwrite) NSNumber *timestamp __deprecated_msg("The timestamp can be set only by the tracker.");

/*! The user event timestamp in milliseconds (epoch time). */
@property (nonatomic, readwrite) NSNumber *trueTimestamp;

/*! The contexts attached to the event. */
@property (nonatomic, readwrite, retain) NSMutableArray *contexts;

/*! The UUID that identifies the event. */
@property (nonatomic, readwrite, retain) NSString *eventId __deprecated_msg("The eventId can be specified only by the tracker.");

/*! The payload of the event. */
@property (nonatomic, readonly) NSDictionary<NSString *, NSObject *> *payload;

- (void) basePreconditions;

/*!
 @brief Get the copy of the context list associated with the event.
*/
- (NSMutableArray *) getContexts;

/*!
 @brief Get the timestamp of the event in milliseconds (epoch time).
 @note If the timestamp is not set, it sets one as a side effect.
 @deprecated This method is for internal use only and will be removed in the next major version.
*/
- (NSNumber *) getTimestamp __deprecated_msg("The timestamp is set only when the event is processed.");

/*!
 @brief Get the user timestamp of the event in seconds (epoch time) if it has been set.
*/
- (NSNumber *)getTrueTimestamp;

/*!
 @brief Get the UUID associated with the event.
 @note If the eventId is not set, it sets one as a side effect.
 @deprecated This method is for internal use only and will be removed in the next major version.
*/
- (NSString *) getEventId __deprecated_msg("The eventId is set only when the event is processed.");

- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb __deprecated_msg("The payload can be updated only by the tracker.");

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
@interface SPSelfDescribing : SPEvent

/*! The schema of the event. */
@property (nonatomic, readonly) NSString *schema;

@end

/*!
 @interface SPPrimitive
 @brief The properties for all the self-describing events.
 */
@interface SPPrimitive : SPEvent

/*! The name of the event. */
@property (nonatomic, readonly) NSString *name;

@end
