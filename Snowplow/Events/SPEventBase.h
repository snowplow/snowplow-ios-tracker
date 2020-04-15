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
 @brief Set the timestamp of the event.

 @param timestamp The timestamp of the event in milliseconds (epoch time)
 */
- (void) setTimestamp:(NSNumber *)timestamp;

/*!
 @brief Set the contexts attached to the event.

 @param contexts An array of contexts (should be self-describing JSONs).
 */
- (void) setContexts:(NSMutableArray *)contexts;

/*!
 @brief Set the UUID associated with the event.

 @param eventId A UUID for the event.
 */
- (void) setEventId:(NSString *)eventId;
@end

/*!
 @class SPEvent
 @brief The base object for all events.

 This class has the basic functionality needed to represent all events.
 */
@interface SPEvent : NSObject <SPEventBuilder>

/*! The event timestamp in milliseconds (epoch time). */
@property (nonatomic, readwrite) NSNumber *timestamp __deprecated_msg("The timestamp can be set only by the tracker.");

/*! The contexts attached to the event. */
@property (nonatomic, readwrite, retain) NSMutableArray *contexts;

/*! The UUID that identifies the event. */
@property (nonatomic, readwrite, retain) NSString *eventId __deprecated_msg("The eventId can be specified only by the tracker.");

/*! The payload of the event. */
@property (nonatomic, readonly) NSDictionary<NSString *, NSObject *> *payload;

- (void) basePreconditions;
- (NSMutableArray *) getContexts;
- (NSNumber *) getTimestamp;
- (NSString *) getEventId;
- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb __deprecated_msg("The payload can be updated only by the tracker.");
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
