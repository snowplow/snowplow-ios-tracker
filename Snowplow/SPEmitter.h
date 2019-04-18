//
//  SPEmitter.h
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
 @file SPEmitter.h

 @brief Header file for SPEmitter.
 */

#import <Foundation/Foundation.h>

@protocol SPRequestCallback;
@class SPPayload;
@class SPEventStore;

/*!
 @brief An enum for HTTP method types.
 */
typedef NS_ENUM(NSInteger, SPRequestOptions) {
    /*! GET request. */
    SPRequestGet,
    /*! POST request. */
    SPRequestPost
};

/*!
 @brief An enum for HTTP security.
 */
typedef NS_ENUM(NSInteger, SPProtocol) {
    /*! Use HTTP. */
    SPHttp,
    /*! Use HTTP over TLS. */
    SPHttps
};

/*!
 @brief The builder for SPEmitter.
 */
@protocol SPEmitterBuilder <NSObject>

/*!
 @brief Emitter builder method to set the collector endpoint.

 @param urlEndpoint The collector endpoint.
 */
- (void) setUrlEndpoint:(NSString *)urlEndpoint;

/*!
 @brief Emitter builder method to set HTTP method.

 @param method Should be SPRequestGet or SPRequestPost.
 */
- (void) setHttpMethod:(SPRequestOptions)method;

/*!
 @brief Emitter builder method to set HTTP security.

 @param protocol Should be SPHttp or SPHttps.
 */
- (void) setProtocol:(SPProtocol)protocol;

/*!
 @brief Emitter builder method to set callbacks.

 @param callback Called on when events have sent.
 */
- (void) setCallback:(id<SPRequestCallback>)callback;

/*!
 @brief Emitter builder method to set emit range.

 @param emitRange Number of events to pull from database.
 */
- (void) setEmitRange:(NSInteger)emitRange;

/*!
 @brief Emitter builder method to set thread pool size.

 @param emitThreadPoolSize The number of threads used by the emitter.
 */
- (void) setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize;

/*!
 @brief Emitter builder method to set byte limit for GET requests.
 @param byteLimitGet Maximum event size for a GET request.
 */
- (void) setByteLimitGet:(NSInteger)byteLimitGet;

/*!
 @brief Emitter builder method to set byte limit for POST requests.
 @param byteLimitPost Maximum event size for a POST request.
 */
- (void) setByteLimitPost:(NSInteger)byteLimitPost;

/*!
 @brief Emitter builder method to set a custom POST path.
 @param customPath A custom path that is used on the endpoint to send requests.
 */
- (void) setCustomPostPath:(NSString *)customPath;

@end

/*!
 @class SPEmitter
 @brief The emitter class.

 This class sends events to the collector.
 */
@interface SPEmitter : NSObject <SPEmitterBuilder>

/*! @brief Chosen HTTP method - SPRequestGet or SPRequestPost. */
@property (readonly, nonatomic) SPRequestOptions              httpMethod;
/*! @brief Security of requests - SPHttp or SPHttps.  */
@property (readonly, nonatomic) SPProtocol                    protocol;
/*! @brief Collector endpoint. */
@property (readonly, nonatomic, retain) NSURL *               urlEndpoint;
/*! @brief Number of events retrieved from the database when needed. */
@property (readonly, nonatomic)         NSInteger             emitRange;
/*! @brief Number of threads used for emitting events. */
@property (readonly, nonatomic)         NSInteger             emitThreadPoolSize;
/*! @brief Byte limit for GET requests. */
@property (readonly, nonatomic)         NSInteger             byteLimitGet;
/*! @brief Byte limit for POST requests. */
@property (readonly, nonatomic)         NSInteger             byteLimitPost;
/*! @brief Callbacks supplied with number of failures and successes of sent events. */
@property (readonly, nonatomic, weak)   id<SPRequestCallback> callback;
/*! @brief Custom endpoint path for POST requests. */
@property (readonly, nonatomic) NSString * customPostPath;

/*!
 @brief Builds the emitter using a build block of functions.
 */
+ (instancetype) build:(void(^)(id<SPEmitterBuilder>builder))buildBlock;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

/*!
 @brief Insert a SPPayload object into the buffer to be sent to collector.

 This method will add the payload to the database and flush (send all events).
 @param spPayload An SPPayload containing a completed event to be added into the buffer.
 */
- (void) addPayloadToBuffer:(SPPayload *)spPayload;

/*!
 @brief Empties the buffer of events using the respective HTTP request method.
 */
- (void) flushBuffer;

/*!
 @brief Sets up a timer to automatically initiate sending of events at pre-determined intervals.
 */
- (void) startTimerFlush;

/*!
 @brief Suspends the timer so flush will not be called.
 */
- (void) stopTimerFlush;

/*!
 @brief Returns the number of events in the DB.

 @return The number of events in DB.
 */
- (NSUInteger) getDbCount;

/*!
 @brief Returns whether the emitter is currently sending.

 @return Whether the emitter is currently sending.
 */
- (BOOL) getSendingStatus;

@end
