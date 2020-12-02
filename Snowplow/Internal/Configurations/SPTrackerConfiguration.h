//
//  SPTrackerConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPDevicePlatform.h"
#import "SPLoggerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerConfiguration.Protocol)
@protocol SPTrackerConfigurationProtocol

@property () NSString *namespace;
@property () NSString *appId;

@property () SPDevicePlatform devicePlatform;
@property () BOOL base64Encoding;

@property () SPLogLevel logLevel;
@property (nullable) id<SPLoggerDelegate> loggerDelegate;

@property () BOOL applicationContext;
@property () BOOL platformContext;
@property () BOOL geoLocationContext;
@property () BOOL sessionContext;
@property () BOOL screenContext;
@property () BOOL screenViewAutotracking;
@property () BOOL lifecycleAutotracking;
@property () BOOL installAutotracking;
@property () BOOL exceptionAutotracking;
@property () BOOL diagnosticAutotracking;

@end

NS_SWIFT_NAME(TrackerConfiguration)
@interface SPTrackerConfiguration : SPConfiguration <SPTrackerConfigurationProtocol>

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithNamespace:(NSString *)namespace appId:(NSString *)appId;

@end

NS_ASSUME_NONNULL_END
