//
//  SPTracker.h
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

/*!
 @file SPTracker.h

 @brief Header file for SPTracker.
 */

#import <Foundation/Foundation.h>

void uncaughtExceptionHandler(NSException *exception);

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
@class SPSelfDescribingJson;
@class SPConsentWithdrawn;
@class SPConsentGranted;
@class SPPushNotification;
@class SPForeground;
@class SPBackground;
@class SPScreenState;
@class SNOWError;

/*!
 @brief The builder for SPTracker.
 */
@protocol SPTrackerBuilder <NSObject>

/*!
 @brief Tracker builder method to set an emitter.

 @param emitter The emitter used by the tracker.
 */
- (void) setEmitter:(SPEmitter *)emitter;

/*!
 @brief Tracker builder method to set a subject.

 The subject represents a current user, and holds associated information

 @param subject An associated subject
 */
- (void) setSubject:(SPSubject *)subject;

/*!
 @brief Tracker builder method to set the app ID.

 @param appId The tracker's app ID.
 */
- (void) setAppId:(NSString *)appId;

/*!
 @brief Tracker builder method to set whether events will be sent Base64 encoded.

 @param base64Encoded Whether events are Base64 encoded
 */
- (void) setBase64Encoded:(BOOL)base64Encoded;

/*!
 @brief Tracker builder method to set the tracker namespace.

 @param trackerNamespace The tracker's namespace.
 */
- (void) setTrackerNamespace:(NSString *)trackerNamespace;

/*!
 @brief Tracker builder method to set whether events will include session context

 @param sessionContext Whether session context is enabled.
 */
- (void) setSessionContext:(BOOL)sessionContext;

/*!
 @brief Tracker builder method to set the foreground timeout.

 @param foregroundTimeout Length of timeout in the foreground in seconds.
 */
- (void) setForegroundTimeout:(NSInteger)foregroundTimeout;

/*!
 @brief Tracker builder method to set the background timeout.

 @param backgroundTimeout Length of timeout in the foreground in seconds.
 */
- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout;

/*!
 @brief Tracker builder method to set the interval of session checking.

 @param checkInterval Length of time in seconds that session checks for timeout.
 */
- (void) setCheckInterval:(NSInteger)checkInterval;

/*!
 @brief Tracker builder method to set whether events will include application context.

 @param applicationContext Whether application context is enabled.
 */
- (void) setApplicationContext:(BOOL)applicationContext;

/*!
 @brief Tracker builder method to set whether screen contexts will be added to all events.
 
 @param screenContext Whether screen contexts are enabled.
 */
- (void) setScreenContext:(BOOL)screenContext;

/*!
 @brief Tracker builder method to set whether foreground and background events are sent on app suspend and resume.

 @param lifecycleEvents Whether foreground and background events are enabled.
 */
- (void) setLifecycleEvents:(BOOL)lifecycleEvents;

/*!
 @brief Tracker builder method to set whether exceptions should be autotracked.
 
 @param exceptionEvents Whether to autotrack exceptions.
 */
- (void) setExceptionEvents:(BOOL)exceptionEvents;

/*!
 @brief Tracker builder method to set whether screenviews will be autotracked.

 @param autotrackScreenViews Whether to autotrack screenviews.
 */
- (void) setAutotrackScreenViews:(BOOL)autotrackScreenViews;

/*!
 @brief Tracker builder method to set whether application install should be autotracked.
 
 @param installEvent Whether to autotrack application installs.
 */
- (void) setInstallEvent:(BOOL)installEvent;

@end

/*!
 @class SPTracker
 @brief The tracker class.

 This class is used for tracking events, and delegates them to other classes responsible for sending, storage, etc.
 */
@interface SPTracker : NSObject <SPTrackerBuilder>

/*! @brief The emitter used to send events. */
@property (readonly, nonatomic, strong) SPEmitter * emitter;
/*! @brief The subject used to represent the current user and persist user information. */
@property (readonly, nonatomic, strong) SPSubject * subject;
/*! @brief The object used for sessionization, i.e. it characterizes user activity. */
@property (nonatomic, retain) SPSession * session;
/*! @brief A unique identifier for an application. */
@property (readonly, nonatomic, strong) NSString * appId;
/*! @brief The identifier for the current tracker. */
@property (readonly, nonatomic, strong) NSString * trackerNamespace;
/*! @brief Whether to use Base64 encoding for events. */
@property (readonly, nonatomic) BOOL base64Encoded;
/*! @brief Previous screen view state. */
@property (readonly, nonatomic, strong) SPScreenState * previousScreenState;
/*! @brief Current screen view state. */
@property (readonly, nonatomic, strong) SPScreenState * currentScreenState;

/*!
 @brief Method that allows for builder pattern in creating the tracker.
 */
+ (instancetype) build:(void(^)(id<SPTrackerBuilder>builder))buildBlock;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (void) receiveScreenViewNotification:(NSNotification *)notification;

/*!
 @brief Pauses all event tracking, storage and session checking.
 */
- (void) pauseEventTracking;

/*!
 @brief Resumes all event tracking and restarts the session checking.
 */
- (void) resumeEventTracking;

/*!
 @brief Returns the current session index count.

 @return A count of sessions that have occurred - also identifies the current session.
 */
- (NSInteger) getSessionIndex;

/*!
 @brief Returns whether the application is in the background or foreground.

 @return Whether application is suspended.
 */
- (BOOL) getInBackground;

/*!
 @brief Returns whether the tracker is currently collecting data.

 @return Whether the tracker is tracking.
 */
- (BOOL) getIsTracking;

/*!
 @brief Returns the session's userId.

 @return UUID for userID.
 */
- (NSString*) getSessionUserId;

/*!
 @brief Returns whether lifecyle events is enabled.

 @return Whether background and foreground events are sent.
 */
- (BOOL) getLifecycleEvents;

/*!
 @brief Constructs the final event payload that is sent to the emitter.

 @warning This function is only used for testing purposes; should never be called in production.

 @param pb The event payload without any decoration.
 @param contextArray The array of SelfDescribingJsons to add to the context JSON.
 @param eventId The event's eventId which will be used to generate the session JSON.
 @return The final complete payload ready for sending.
 */
- (SPPayload *) getFinalPayloadWithPayload:(SPPayload *)pb andContext:(NSMutableArray *)contextArray andEventId:(NSString *)eventId;

/*!
 @brief Tracks a page view event.

 @param event A page view event.
 */
- (void) trackPageViewEvent:(SPPageView *)event;

/*!
 @brief Tracks a structured event.

 @param event A structured event.
 */
- (void) trackStructuredEvent:(SPStructured *)event;

/*!
 @brief Tracks an unstructured event.

 @param event An unstructured event.
 */
- (void) trackUnstructuredEvent:(SPUnstructured *)event;

/*!
 @brief Tracks an self-describing event.

 @note This is an alias for trackUnstructuredEvent:event.

 @param event An self-describing JSON.
 */
- (void) trackSelfDescribingEvent:(SPSelfDescribingJson *)event;

/*!
 @brief Tracks an screenview event.

 @param event A screenview event.
 */
- (void) trackScreenViewEvent:(SPScreenView *) event;

/*!
 @brief Tracks a timing event.

 @param event A timing event.
 */
- (void) trackTimingEvent:(SPTiming *) event;

/*!
 @brief Tracks an ecommerce event.

 @param event An ecommerce event.
 */
- (void) trackEcommerceEvent:(SPEcommerce *)event;

/*!
 @brief Tracks a consent withdrawn event.

 @param event A consent withdrawn event.
 */
- (void) trackConsentWithdrawnEvent:(SPConsentWithdrawn *)event;

/*!
 @brief Tracks a consent granted event.

 @param event A consent granted event.
 */
- (void) trackConsentGrantedEvent:(SPConsentGranted *)event;

/*!
 @brief Tracks a push notification event.

 @param event A push notification event.
 */
- (void) trackPushNotificationEvent:(SPPushNotification *)event;

/*!
 @brief Tracks a foreground event.

 @param event A foreground event.
 */
- (void) trackForegroundEvent:(SPForeground *)event;

/*!
 @brief Tracks a background event.

 @param event A background event.
 */
- (void) trackBackgroundEvent:(SPBackground *)event;

/*!
 @brief Tracks an error event.
 
 @param event An error event.
 */
- (void) trackErrorEvent:(SNOWError *)event;

@end
