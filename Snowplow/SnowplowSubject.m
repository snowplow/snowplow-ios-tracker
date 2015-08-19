//
//  SnowplowSubject.m
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
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SnowplowSubject.h"
#import "SnowplowUtils.h"

@implementation SnowplowSubject {
    SnowplowPayload * _standardDict;
    SnowplowPayload * _platformDict;
}

- (id) init {
    return [self initWithPlatformContext:false];
}

- (id) initWithPlatformContext:(BOOL)platformContext {
    self = [super init];
    if (self) {
        _standardDict = [[SnowplowPayload alloc] init];
        [self setStandardDict];
        if (platformContext) {
            [self setPlatformDict];
        }
    }
    return self;
}

- (SnowplowPayload *) getStandardDict {
    return _standardDict;
}

- (SnowplowPayload *) getPlatformDict {
    return _platformDict;
}

// Standard Dictionary

- (void) setStandardDict {
    [_standardDict addValueToPayload:[SnowplowUtils getPlatform] forKey:@"p"];
    [_standardDict addValueToPayload:[SnowplowUtils getResolution] forKey:@"res"];
    [_standardDict addValueToPayload:[SnowplowUtils getViewPort] forKey:@"vp"];
    [_standardDict addValueToPayload:[SnowplowUtils getEventId] forKey:@"eid"];
    [_standardDict addValueToPayload:[SnowplowUtils getLanguage] forKey:@"lang"];
}

// Platform Dictionary

- (void) setPlatformDict {
    _platformDict = [[SnowplowPayload alloc] init];
#if TARGET_OS_IPHONE
    [self setMobileDict];
#else
    [self setDesktopDict];
#endif
}

- (void) setMobileDict {
    [_platformDict addValueToPayload:[SnowplowUtils getOSType] forKey:@"osType"];
    [_platformDict addValueToPayload:[SnowplowUtils getOSVersion] forKey:@"osVersion"];
    [_platformDict addValueToPayload:[SnowplowUtils getDeviceVendor] forKey:@"deviceManufacturer"];
    [_platformDict addValueToPayload:[SnowplowUtils getDeviceModel] forKey:@"deviceModel"];
    [_platformDict addValueToPayload:[SnowplowUtils getCarrierName] forKey:@"carrier"];
    [_platformDict addValueToPayload:[SnowplowUtils getOpenIdfa] forKey:@"openIdfa"];
    [_platformDict addValueToPayload:[SnowplowUtils getAppleIdfa] forKey:@"appleIdfa"];
    [_platformDict addValueToPayload:[SnowplowUtils getAppleIdfv] forKey:@"appleIdfv"];
    [_platformDict addValueToPayload:[SnowplowUtils getNetworkType] forKey:@"networkType"];
    [_platformDict addValueToPayload:[SnowplowUtils getNetworkTechnology] forKey:@"networkTechnology"];
}

- (void) setDesktopDict {
    [_platformDict addValueToPayload:[SnowplowUtils getOSType] forKey:@"osType"];
    [_platformDict addValueToPayload:[SnowplowUtils getOSVersion] forKey:@"osVersion"];
    [_platformDict addValueToPayload:[SnowplowUtils getDeviceVendor] forKey:@"deviceManufacturer"];
    [_platformDict addValueToPayload:[SnowplowUtils getDeviceModel] forKey:@"deviceModel"];
}

@end
