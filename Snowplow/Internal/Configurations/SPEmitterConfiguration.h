//
//  SPEmitterConfiguration.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPEventStore.h"
#import "SPRequestCallback.h"

/*!
 @brief An enum for buffer options.
 */
typedef NS_ENUM(NSUInteger, SPBufferOption) {
    /**
     * Sends both GET and POST requests with only a single event.  Can cause a spike in
     * network traffic if used in correlation with a large amount of events.
     */
    SPBufferOptionSingle = 1,
    /**
     * Sends POST requests in groups of 10 events.  This is the default amount of events too
     * package into a POST.  All GET requests will still emit one at a time.
     */
    SPBufferOptionDefaultGroup = 10,
    /**
     * Sends POST requests in groups of 25 events.  Useful for situations where many events
     * need to be sent.  All GET requests will still emit one at a time.
     */
    SPBufferOptionHeavyGroup = 25
} NS_SWIFT_NAME(BufferOption);


NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(EmitterConfigurationProtocol)
@protocol SPEmitterConfigurationProtocol

@property () SPBufferOption bufferOption;
@property () NSInteger emitRange;
@property () NSInteger emitThreadPoolSize;
@property () NSInteger byteLimitGet;
@property () NSInteger byteLimitPost;
@property (nullable) id<SPRequestCallback> requestCallback;

@end

NS_SWIFT_NAME(EmitterConfiguration)
@interface SPEmitterConfiguration : SPConfiguration <SPEmitterConfigurationProtocol>

@property (nullable) id<SPEventStore> eventStore;

SP_BUILDER_DECLARE(SPBufferOption, bufferOption)
SP_BUILDER_DECLARE(NSInteger, emitRange)
SP_BUILDER_DECLARE(NSInteger, emitThreadPoolSize)
SP_BUILDER_DECLARE(NSInteger, byteLimitGet)
SP_BUILDER_DECLARE(NSInteger, byteLimitPost)
SP_BUILDER_DECLARE_NULLABLE(id<SPRequestCallback>, requestCallback)

SP_BUILDER_DECLARE_NULLABLE(id<SPEventStore>, eventStore)

@end

NS_ASSUME_NONNULL_END
