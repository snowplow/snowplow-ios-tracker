//
//  SPTracker.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

/*!
 @file SPTracker.h

 @brief Header file for SPTracker.
 */

#import <Foundation/Foundation.h>
#import "SPNetworkConfiguration.h"
#import "SPGDPRConfiguration.h"

#import "SPTrackerController.h"
#import "SPSessionController.h"

#import "SPEmitterEventProcessing.h"

#import "SPDevicePlatform.h"
#import "SPEventBase.h"
#import "SPLoggerDelegate.h"
#import "SPGdprContext.h"


void uncaughtExceptionHandler(NSException * _Nullable exception);

@class SPEmitter;
@class SPPayload;
@class SPSubject;
@class SPSession;
@class SPPageView;
@class SPStructured;
@class SPSelfDescribing;
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

@class SPGlobalContext;

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief The builder for SPTracker.
 */
NS_SWIFT_NAME(TrackerBuilder)
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
- (void) setSubject:(nullable SPSubject *)subject;

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
 Internal use only.
 Decorate the `tv` (tracker version) field in the tracker protocol.
 */
- (void) setTrackerVersionSuffix:(NSString *)trackerVersionSuffix;

/*!
 @brief Tracker builder method to set the device platform the tracker is running on
 @param devicePlatform The SPDevicePlatform enum indicating the current platform.
 */
- (void) setDevicePlatform:(SPDevicePlatform)devicePlatform;

/*!
 @brief Tracker builder method to set the log level desired for logging.
 @param logLevel The SPLogLevel enum indicating the current log level.
 */
- (void) setLogLevel:(SPLogLevel)logLevel;

/*!
 @brief Tracker builder method to set the delegate for log messages tracker's generated.
 @param delegate The logger delegate that received logs from the tracker.
*/
- (void)setLoggerDelegate:(nullable id<SPLoggerDelegate>)delegate;

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
 @brief Tracker builder method to set whether events will include application context.
 @param applicationContext Whether application context is enabled.
 */
- (void) setApplicationContext:(BOOL)applicationContext;

/*!
 @brief Tracker builder method to set whether deepLink contexts will be added to ScreenView events.
 @param deepLinkContext Whether screen contexts are enabled.
 */
- (void) setDeepLinkContext:(BOOL)deepLinkContext;

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

/*!
 @brief Tracker builder method to set whether tracker should send tracker diagnostic events.
 @param trackerDiagnostic Whether to enable tracker diagnostic.
 */
- (void) setTrackerDiagnostic:(BOOL)trackerDiagnostic;

/*!
 @brief Add global context generators to be used by tracker.
 @param globalContexts The global context generators to be used and related string tag for identification.
 */
- (void)setGlobalContextGenerators:(NSDictionary<NSString *, SPGlobalContext *> *)globalContexts;

/*!
 @brief Tracker builder method to set a GDPR context for the tracker
 @param basisForProcessing Enum one of valid legal bases for processing.
 @param documentId Document ID.
 @param documentVersion Version of the document.
 @param documentDescription Description of the document.
 */
- (void)setGdprContextWithBasis:(SPGdprProcessingBasis)basisForProcessing
                     documentId:(nullable NSString *)documentId
                documentVersion:(nullable NSString *)documentVersion
            documentDescription:(nullable NSString *)documentDescription;

/*!
 @brief Tracker builder method to set whether to anonymise client-side user identifiers in session and platform context entities.
 @param userAnonymisation Whether to anonymise client-side user identifiers in session and platform context entities
 */
- (void) setUserAnonymisation:(BOOL)userAnonymisation;

@end


/*!
 This class is used for tracking events, and delegates them to other classes responsible for sending, storage, etc.
 */
@interface SPTracker : NSObject <SPTrackerBuilder>

/*! @brief The emitter used to send events. */
@property (readonly, nonatomic, strong) SPEmitter * emitter;
/*! @brief The subject used to represent the current user and persist user information. */
@property (readonly, nonatomic, strong) SPSubject * subject;
/*! @brief The object used for sessionization, i.e. it characterizes user activity. */
@property (readonly, nonatomic, strong) SPSession *session;
/*! @brief A unique identifier for an application. */
@property (readonly, nonatomic, strong) NSString * appId;
/*! @brief The identifier for the current tracker. */
@property (readonly, nonatomic, strong) NSString * trackerNamespace;
/*! @brief Whether to use Base64 encoding for events. */
@property (readonly, nonatomic) BOOL base64Encoded;
/*! @brief Whether to use Base64 encoding for events. */
@property (readonly, nonatomic) SPDevicePlatform devicePlatform;
/*! @brief Version suffix for tracker wrappers. */
@property (readonly, nonatomic) NSString *trackerVersionSuffix;
/*! @brief Previous screen view state. */
@property (readonly, nonatomic, strong) SPScreenState * previousScreenState;
/*! @brief Current screen view state. */
@property (readonly, nonatomic, strong) SPScreenState * currentScreenState;
/*! @brief List of tags associated to global contexts. */
@property (readonly, nonatomic) NSArray<NSString *> *globalContextTags;
/*! @brief Dictionary of global contexts generators. */
@property (nonatomic) NSMutableDictionary<NSString *, SPGlobalContext *> *globalContextGenerators;

// MARK: - Added property methods

- (BOOL)applicationContext;
- (BOOL)exceptionEvents;
- (BOOL)installEvent;
- (BOOL)deepLinkContext;
- (BOOL)screenContext;
- (BOOL)autoTrackScreenView;
- (BOOL)sessionContext;
- (BOOL)trackerDiagnostic;
- (BOOL)userAnonymisation;

// MARK: - methods

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
 @brief Returns whether lifecyle events is enabled.
 @return Whether background and foreground events are sent.
 */
- (BOOL) getLifecycleEvents;

/*!
 Add new generator for global contexts associated with a string tag.
 If the string tag has been already set the new global context is not assigned.
 @param generator The global context generator.
 @param tag The tag associated to the global context.
 @return Weather the global context has been added.
 */
- (BOOL)addGlobalContext:(SPGlobalContext *)generator tag:(NSString *)tag;

/*!
 Remove the global context associated with the string tag.
 If the string tag exist it returns the global context generator associated with.
 @param tag The tag associated to the global context.
 @return The global context associated with the tag or `nil` in case of any entry with that string tag.
 */
- (nullable SPGlobalContext *)removeGlobalContext:(NSString *)tag;

/*!
 Enables GDPR context to be sent with every event.
 @param basisForProcessing GDPR Basis for processing.
 @param documentId ID of a GDPR basis document.
 @param documentVersion Version of the document.
 @param documentDescription Description of the document.
 */
- (void)enableGdprContextWithBasis:(SPGdprProcessingBasis)basisForProcessing
                        documentId:(nullable NSString *)documentId
                   documentVersion:(nullable NSString *)documentVersion
               documentDescription:(nullable NSString *)documentDescription;

/// Disable GDPR context.
- (void)disableGdprContext;

/// Return GDPR context
- (nullable SPGdprContext *)gdprContext;

#pragma mark - Events tracking methods

/*!
 @brief Tracks an event despite its specific type.
 @param event The event to track
 @return The event ID or nil in case tracking is paused
 */
- (nullable NSUUID *)track:(SPEvent *)event;

@end

NS_ASSUME_NONNULL_END
