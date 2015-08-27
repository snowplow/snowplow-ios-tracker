//
//  SPSubject.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPUtils.h"

@implementation SPSubject {
    SPPayload * _standardDict;
    SPPayload * _platformDict;
}

- (id) init {
    return [self initWithPlatformContext:false];
}

- (id) initWithPlatformContext:(BOOL)platformContext {
    self = [super init];
    if (self) {
        _standardDict = [[SPPayload alloc] init];
        [self setStandardDict];
        if (platformContext) {
            [self setPlatformDict];
        }
    }
    return self;
}

- (SPPayload *) getStandardDict {
    return _standardDict;
}

- (SPPayload *) getPlatformDict {
    return _platformDict;
}

// Standard Dictionary

- (void) setStandardDict {
    [_standardDict addValueToPayload:[SPUtils getPlatform]   forKey:kPlatform];
    [_standardDict addValueToPayload:[SPUtils getResolution] forKey:kResolution];
    [_standardDict addValueToPayload:[SPUtils getViewPort]   forKey:kViewPort];
    [_standardDict addValueToPayload:[SPUtils getLanguage]   forKey:kLanguage];
}

- (void) setUserId:(NSString *)uid {
    [_standardDict addValueToPayload:uid forKey:kUid];
}

- (void) setResolutionWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    NSString * res = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
    [_standardDict addValueToPayload:res forKey:kResolution];
}

- (void) setViewPortWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    NSString * res = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
    [_standardDict addValueToPayload:res forKey:kViewPort];
}

- (void) setColorDepth:(NSInteger)depth {
    NSString * res = [NSString stringWithFormat:@"%ld", (long)depth];
    [_standardDict addValueToPayload:res forKey:kColorDepth];
}

- (void) setTimezone:(NSString *)timezone {
    [_standardDict addValueToPayload:timezone forKey:kTimezone];
}

- (void) setLanguage:(NSString *)lang {
    [_standardDict addValueToPayload:lang forKey:kLanguage];
}

- (void) setIpAddress:(NSString *)ip {
    [_standardDict addValueToPayload:ip forKey:kIpAddress];
}

- (void) setUseragent:(NSString *)useragent {
    [_standardDict addValueToPayload:useragent forKey:kUseragent];
}

- (void) setNetworkUserId:(NSString *)nuid {
    [_standardDict addValueToPayload:nuid forKey:kNetworkUid];
}

- (void) setDomainUserId:(NSString *)duid {
    [_standardDict addValueToPayload:duid forKey:kDomainUid];
}

// Platform Dictionary

- (void) setPlatformDict {
    _platformDict = [[SPPayload alloc] init];
#if TARGET_OS_IPHONE
    [self setMobileDict];
#else
    [self setDesktopDict];
#endif
}

- (void) setMobileDict {
    [_platformDict addValueToPayload:[SPUtils getOSType]            forKey:kPlatformOsType];
    [_platformDict addValueToPayload:[SPUtils getOSVersion]         forKey:kPlatformOsVersion];
    [_platformDict addValueToPayload:[SPUtils getDeviceVendor]      forKey:kPlatformDeviceManu];
    [_platformDict addValueToPayload:[SPUtils getDeviceModel]       forKey:kPlatformDeviceModel];
    [_platformDict addValueToPayload:[SPUtils getCarrierName]       forKey:kMobileCarrier];
    [_platformDict addValueToPayload:[SPUtils getOpenIdfa]          forKey:kMobileOpenIdfa];
    [_platformDict addValueToPayload:[SPUtils getAppleIdfa]         forKey:kMobileAppleIdfa];
    [_platformDict addValueToPayload:[SPUtils getAppleIdfv]         forKey:kMobileAppleIdfv];
    [_platformDict addValueToPayload:[SPUtils getNetworkType]       forKey:kMobileNetworkType];
    [_platformDict addValueToPayload:[SPUtils getNetworkTechnology] forKey:kMobileNetworkTech];
}

- (void) setDesktopDict {
    [_platformDict addValueToPayload:[SPUtils getOSType]            forKey:kPlatformOsType];
    [_platformDict addValueToPayload:[SPUtils getOSVersion]         forKey:kPlatformOsVersion];
    [_platformDict addValueToPayload:[SPUtils getDeviceVendor]      forKey:kPlatformDeviceManu];
    [_platformDict addValueToPayload:[SPUtils getDeviceModel]       forKey:kPlatformDeviceModel];
}

@end
