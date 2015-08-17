//
//  ViewController.h
//  SnowplowDemo
//
//  Created by Joshua Beemster on 06/08/2015.
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestCallback.h"
#import "SnowplowEmitter.h"

@interface ViewController : UIViewController <UITextFieldDelegate, RequestCallback>

/**
 * Performs initial Application setup:
 * - Starts a recurring updater to get the database counts
 */
- (void) setup;

/**
 * Initiates the sending of Demo Events to the endpoint.
 * @param sender The ID of the action button
 */
- (IBAction) trackEvents:(id)sender;

/**
 * Updates the metrics for the application
 */
- (void) updateMetrics;

/**
 * Gets the Collector URL from the input TextField
 */
- (NSString *) getCollectorUrl;

/**
 * Gets the Request Method Type that has been selected
 */
- (NSString *) getMethodType;

@end
