//
//  ViewController.h
//  SnowplowDemo
//
//  Copyright (c) 2015-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <UIKit/UIKit.h>
#import "SPRequestCallback.h"

@interface ViewController : UIViewController <UITextFieldDelegate, SPRequestCallback>

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

@end
