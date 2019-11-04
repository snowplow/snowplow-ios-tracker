//
//  DemoUtils.h
//  SnowplowDemo
//
//  Copyright (c) 2015-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015-2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPTracker;
@class SPPayload;

@interface DemoUtils : NSObject

/**
 * Tracks all types of events with a Tracker
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackAll:(SPTracker *)tracker_;

/**
 * Tracks 4 Structured Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackStructuredEventWithTracker:(SPTracker *)tracker_;

/**
 * Tracks 4 Unstructured Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackUnstructuredEventWithTracker:(SPTracker *)tracker_;

/**
 * Tracks 4 Page View Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackPageViewWithTracker:(SPTracker *)tracker_;

/**
 * Tracks 4 Screen View Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackScreenViewWithTracker:(SPTracker *)tracker_;

/**
 * Tracks 4 Timing With Category Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackTimingWithCategoryWithTracker:(SPTracker *)tracker_;

/**
 * Tracks 4 Ecommerce Transactions with 1 item each (8 events)
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackEcommerceTransactionWithTracker:(SPTracker *)tracker_;

/**
 * Returns a pre-built custom context ready for embedding in an event
 * @return The custom context
 */
+ (NSMutableArray *) getCustomContext;

@end
