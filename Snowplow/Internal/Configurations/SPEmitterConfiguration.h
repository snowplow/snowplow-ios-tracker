//
//  SPEmitterConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPNetworkConnection.h"
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

@property (nullable) id<SPNetworkConnection> networkConnection;
@property (nullable) id<SPEventStore> eventStore;

SP_BUILDER_DECLARE(SPBufferOption, bufferOption)
SP_BUILDER_DECLARE(NSInteger, emitRange)
SP_BUILDER_DECLARE(NSInteger, emitThreadPoolSize)
SP_BUILDER_DECLARE(NSInteger, byteLimitGet)
SP_BUILDER_DECLARE(NSInteger, byteLimitPost)
SP_BUILDER_DECLARE_NULLABLE(id<SPRequestCallback>, requestCallback)

SP_BUILDER_DECLARE_NULLABLE(id<SPNetworkConnection>, networkConnection)
SP_BUILDER_DECLARE_NULLABLE(id<SPEventStore>, eventStore)

@end

NS_ASSUME_NONNULL_END
