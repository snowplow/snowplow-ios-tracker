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
#import "SPUtilities.h"

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
    [_standardDict addValueToPayload:[SPUtilities getPlatform]   forKey:kSPPlatform];
    [_standardDict addValueToPayload:[SPUtilities getResolution] forKey:kSPResolution];
    [_standardDict addValueToPayload:[SPUtilities getViewPort]   forKey:kSPViewPort];
    [_standardDict addValueToPayload:[SPUtilities getLanguage]   forKey:kSPLanguage];
}

- (void) setUserId:(NSString *)uid {
    [_standardDict addValueToPayload:uid forKey:kSPUid];
}

- (void) setResolutionWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    NSString * res = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
    [_standardDict addValueToPayload:res forKey:kSPResolution];
}

- (void) setViewPortWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    NSString * res = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
    [_standardDict addValueToPayload:res forKey:kSPViewPort];
}

- (void) setColorDepth:(NSInteger)depth {
    NSString * res = [NSString stringWithFormat:@"%ld", (long)depth];
    [_standardDict addValueToPayload:res forKey:kSPColorDepth];
}

- (void) setTimezone:(NSString *)timezone {
    [_standardDict addValueToPayload:timezone forKey:kSPTimezone];
}

- (void) setLanguage:(NSString *)lang {
    [_standardDict addValueToPayload:lang forKey:kSPLanguage];
}

- (void) setIpAddress:(NSString *)ip {
    [_standardDict addValueToPayload:ip forKey:kSPIpAddress];
}

- (void) setUseragent:(NSString *)useragent {
    [_standardDict addValueToPayload:useragent forKey:kSPUseragent];
}

- (void) setNetworkUserId:(NSString *)nuid {
    [_standardDict addValueToPayload:nuid forKey:kSPNetworkUid];
}

- (void) setDomainUserId:(NSString *)duid {
    [_standardDict addValueToPayload:duid forKey:kSPDomainUid];
}

// Platform Dictionary

- (void) setPlatformDict {
    _platformDict = [[SPPayload alloc] init];
    [_platformDict addValueToPayload:[SPUtilities getOSType]            forKey:kSPPlatformOsType];
    [_platformDict addValueToPayload:[SPUtilities getOSVersion]         forKey:kSPPlatformOsVersion];
    [_platformDict addValueToPayload:[SPUtilities getDeviceVendor]      forKey:kSPPlatformDeviceManu];
    [_platformDict addValueToPayload:[SPUtilities getDeviceModel]       forKey:kSPPlatformDeviceModel];
#if TARGET_OS_IPHONE
    [self setMobileDict];
#endif
}

- (void) setMobileDict {
    [_platformDict addValueToPayload:[SPUtilities getCarrierName]       forKey:kSPMobileCarrier];
    [_platformDict addValueToPayload:[SPUtilities getOpenIdfa]          forKey:kSPMobileOpenIdfa];
    [_platformDict addValueToPayload:[SPUtilities getAppleIdfa]         forKey:kSPMobileAppleIdfa];
    [_platformDict addValueToPayload:[SPUtilities getAppleIdfv]         forKey:kSPMobileAppleIdfv];
    [_platformDict addValueToPayload:[SPUtilities getNetworkType]       forKey:kSPMobileNetworkType];
    [_platformDict addValueToPayload:[SPUtilities getNetworkTechnology] forKey:kSPMobileNetworkTech];
}

@end
