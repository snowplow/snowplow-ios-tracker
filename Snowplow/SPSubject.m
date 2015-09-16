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
#import "SPUtilites.h"

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
    [_standardDict addValueToPayload:[SPUtilites getPlatform]   forKey:kSPPlatform];
    [_standardDict addValueToPayload:[SPUtilites getResolution] forKey:kSPResolution];
    [_standardDict addValueToPayload:[SPUtilites getViewPort]   forKey:kSPViewPort];
    [_standardDict addValueToPayload:[SPUtilites getLanguage]   forKey:kSPLanguage];
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
    [_platformDict addValueToPayload:[SPUtilites getOSType]            forKey:kSPPlatformOsType];
    [_platformDict addValueToPayload:[SPUtilites getOSVersion]         forKey:kSPPlatformOsVersion];
    [_platformDict addValueToPayload:[SPUtilites getDeviceVendor]      forKey:kSPPlatformDeviceManu];
    [_platformDict addValueToPayload:[SPUtilites getDeviceModel]       forKey:kSPPlatformDeviceModel];
#if TARGET_OS_IPHONE
    [self setMobileDict];
#endif
}

- (void) setMobileDict {
    [_platformDict addValueToPayload:[SPUtilites getCarrierName]       forKey:kSPMobileCarrier];
    [_platformDict addValueToPayload:[SPUtilites getOpenIdfa]          forKey:kSPMobileOpenIdfa];
    [_platformDict addValueToPayload:[SPUtilites getAppleIdfa]         forKey:kSPMobileAppleIdfa];
    [_platformDict addValueToPayload:[SPUtilites getAppleIdfv]         forKey:kSPMobileAppleIdfv];
    [_platformDict addValueToPayload:[SPUtilites getNetworkType]       forKey:kSPMobileNetworkType];
    [_platformDict addValueToPayload:[SPUtilites getNetworkTechnology] forKey:kSPMobileNetworkTech];
}

@end
