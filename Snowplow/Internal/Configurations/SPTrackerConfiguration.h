//
//  SPTrackerConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDevicePlatform.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerConfiguration)
@interface SPTrackerConfiguration : NSObject

@property () NSString *namespace;
@property () NSString *appId;

@property () SPDevicePlatform devicePlatform;
@property () BOOL base64Encoding;

@property () BOOL sessionContext;
@property () BOOL applicationContext;
@property () BOOL screenContext;
@property () BOOL screenViewAutotracking;
@property () BOOL lifecycleAutotracking;
@property () BOOL installAutotracking;
@property () BOOL exceptionAutotracking;
@property () BOOL diagnosticAutotracking;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithNamespace:(NSString *)namespace appId:(NSString *)appId;

@end

NS_ASSUME_NONNULL_END
