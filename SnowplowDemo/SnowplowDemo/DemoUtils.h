//
//  DemoUtils.h
//  SnowplowDemo
//
//  Created by Joshua Beemster on 06/08/2015.
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnowplowPayload.h"
#import "SnowplowTracker.h"

@interface DemoUtils : NSObject

/**
 * Tracks all types of events with a Tracker
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackAll:(SnowplowTracker *)tracker_;

/**
 * Tracks 4 Structured Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackStructuredEventWithTracker:(SnowplowTracker *)tracker_;

/**
 * Tracks 4 Unstructured Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackUnstructuredEventWithTracker:(SnowplowTracker *)tracker_;

/**
 * Tracks 4 Page View Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackPageViewWithTracker:(SnowplowTracker *)tracker_;

/**
 * Tracks 4 Screen View Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackScreenViewWithTracker:(SnowplowTracker *)tracker_;

/**
 * Tracks 4 Timing With Category Events
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackTimingWithCategoryWithTracker:(SnowplowTracker *)tracker_;

/**
 * Tracks 4 Ecommerce Transactions with 1 item each (8 events)
 * @param tracker_ The tracker to use for the Tracking
 */
+ (void) trackEcommerceTransactionWithTracker:(SnowplowTracker *)tracker_;

/**
 * Returns a pre-built custom context ready for embedding in an event
 * @return The custom context
 */
+ (NSMutableArray *) getCustomContext;

@end
