//
//  SPTracker.h
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPEmitter;
@class SPPayload;
@class SPSubject;
@class SPSession;
@class SPPageView;
@class SPStructured;
@class SPUnstructured;
@class SPScreenView;
@class SPTiming;
@class SPEcommerce;

@protocol SPTrackerBuilder <NSObject>

- (void) setEmitter:(SPEmitter *)emitter;
- (void) setSubject:(SPSubject *)subject;
- (void) setAppId:(NSString *)appId;
- (void) setBase64Encoded:(BOOL)base64Encoded;
- (void) setTrackerNamespace:(NSString *)trackerNamespace;
- (void) setSessionContext:(BOOL)sessionContext;
- (void) setForegroundTimeout:(NSInteger)foregroundTimeout;
- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout;
- (void) setCheckInterval:(NSInteger)checkInterval;

@end

@interface SPTracker : NSObject <SPTrackerBuilder>

@property (readonly, nonatomic, retain) SPEmitter * emitter;
@property (readonly, nonatomic, retain) SPSubject * subject;
@property (readonly, nonatomic, retain) NSString *  appId;
@property (readonly, nonatomic, retain) NSString *  trackerNamespace;
@property (readonly, nonatomic)         BOOL        base64Encoded;

/**
 * Builds the Tracker using a build block of functions.
 */
+ (instancetype) build:(void(^)(id<SPTrackerBuilder>builder))buildBlock;

/**
 *  Initializes a newly allocated SnowplowTracker.
 *  @return A SnowplowTracker instance.
 */
- (id) init;

/**
 * Pauses all event tracking, storage and session checking.
 */
- (void) pauseEventTracking;

/**
 * Resumes all event tracking and restarts the session checking.
 */
- (void) resumeEventTracking;

/**
 * Returns the current session index count
 * @return a count of sessions
 */
- (NSInteger) getSessionIndex;

/**
 * Returns whether the application is in the background or foreground
 * @return boolean truth of application location
 */
- (BOOL) getInBackground;

/**
 * Returns whether the Tracker is currently collecting data.
 * @return the boolean state of the tracker (on/off)
 */
- (BOOL) getIsTracking;

/**
 * Constructs the final event payload that is sent to the emitter.
 * NOTE: This function is only used for testing purposes; should never be called in production.
 *
 * @param pb The event payload without any decoration
 * @param contextArray The array of SelfDescribingJsons to add to the context json
 * @param eventId The events eventId which will be used to generate the session json
 * @return the final complete payload ready for sending
 */
- (SPPayload *) getFinalPayloadWithPayload:(SPPayload *)pb andContext:(NSMutableArray *)contextArray andEventId:(NSString *)eventId;

/**
 * Tracks a PageView Event object.
 */
- (void) trackPageViewEvent:(SPPageView *)event;

/**
 * Tracks a Structured Event object.
 */
- (void) trackStructuredEvent:(SPStructured *)event;

/**
 * Tracks an Unstructured Event object.
 */
- (void) trackUnstructuredEvent:(SPUnstructured *)event;

/**
 * Tracks a ScreenView Event object.
 */
- (void) trackScreenViewEvent:(SPScreenView *) event;

/**
 * Tracks a Timing Event object.
 */
- (void) trackTimingEvent:(SPTiming *) event;

/**
 * Tracks an Ecommerce Event object.
 */
- (void) trackEcommerceEvent:(SPEcommerce *)event;

@end
