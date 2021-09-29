//
//  SPPlatformContext.h
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
//  Authors: Matus Tomlein
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPPlatformContext.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#if SNOWPLOW_TARGET_IOS
#import <UIKit/UIScreen.h>
#endif

@implementation SPPlatformContext {
    SPPayload * _platformDict;
    NSTimeInterval _mobileDictUpdateFrequency;
    NSTimeInterval _networkDictUpdateFrequency;
    NSTimeInterval _lastUpdatedEphemeralMobileDict;
    NSTimeInterval _lastUpdatedEphemeralNetworkDict;
    long _countEphemeralMobileDictUpdates;
    long _countEphemeralNetworkDictUpdates;
}

- (id) init {
    return [self initWithMobileDictUpdateFrequency:0.1 andNetworkDictUpdateFrequency:10.0];
}

- (id) initWithMobileDictUpdateFrequency:(NSTimeInterval)mobileDictUpdateFrequency andNetworkDictUpdateFrequency:(NSTimeInterval) networkDictUpdateFrequency {
    if (self = [super init]) {
        _mobileDictUpdateFrequency = mobileDictUpdateFrequency;
        _networkDictUpdateFrequency = networkDictUpdateFrequency;
        _countEphemeralMobileDictUpdates = 0;
        _countEphemeralNetworkDictUpdates = 0;
#if SNOWPLOW_TARGET_IOS
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
#endif
        [self setPlatformDict];
    }
    return self;
}

- (SPPayload *) fetchPlatformDict {
#if SNOWPLOW_TARGET_IOS
    @synchronized (self) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (now - _lastUpdatedEphemeralMobileDict >= _mobileDictUpdateFrequency) {
            [self setEphemeralMobileDict];
        }
        if (now - _lastUpdatedEphemeralNetworkDict >= _networkDictUpdateFrequency) {
            [self setEphemeralNetworkDict];
        }
    }
#endif
    return _platformDict;
}

- (long) getCountEphemeralMobileDictUpdates {
    return _countEphemeralMobileDictUpdates;
}

- (long) getCountEphemeralNetworkDictUpdates {
    return _countEphemeralNetworkDictUpdates;
}

// MARK: - Private methods

- (void) setPlatformDict {
    _platformDict = [[SPPayload alloc] init];
    [_platformDict addValueToPayload:[SPUtilities getOSType]            forKey:kSPPlatformOsType];
    [_platformDict addValueToPayload:[SPUtilities getOSVersion]         forKey:kSPPlatformOsVersion];
    [_platformDict addValueToPayload:[SPUtilities getDeviceVendor]      forKey:kSPPlatformDeviceManu];
    [_platformDict addValueToPayload:[SPUtilities getDeviceModel]       forKey:kSPPlatformDeviceModel];
#if SNOWPLOW_TARGET_IOS
    [self setMobileDict];
#endif
}

- (void) setMobileDict {
    [_platformDict addValueToPayload:[SPUtilities getCarrierName]         forKey:kSPMobileCarrier];
    [_platformDict addValueToPayload:[SPUtilities getAppleIdfa]           forKey:kSPMobileAppleIdfa];
    [_platformDict addValueToPayload:[SPUtilities getAppleIdfv]           forKey:kSPMobileAppleIdfv];
    [_platformDict addNumericValueToPayload:[SPUtilities getTotalStorage] forKey:kSPMobileTotalStorage];
    [self setEphemeralMobileDict];
    [self setEphemeralNetworkDict];
}

- (void) setEphemeralMobileDict {
    _lastUpdatedEphemeralMobileDict = [[NSDate date] timeIntervalSince1970];
    _countEphemeralMobileDictUpdates++;
    [_platformDict addNumericValueToPayload:[SPUtilities getBatteryLevel]       forKey:kSPMobileBatteryLevel];
    [_platformDict addValueToPayload:[SPUtilities getBatteryState]              forKey:kSPMobileBatteryState];
    [_platformDict addNumericValueToPayload:[SPUtilities isLowPowerModeEnabled] forKey:kSPMobileLowPowerMode];
    [_platformDict addNumericValueToPayload:[SPUtilities getAvailableStorage]   forKey:kSPMobileAvailableStorage];
    [_platformDict addNumericValueToPayload:[SPUtilities getAppAvailableMemory] forKey:kSPMobileAppAvailableMemory];
}

- (void) setEphemeralNetworkDict {
    _lastUpdatedEphemeralNetworkDict = [[NSDate date] timeIntervalSince1970];
    _countEphemeralNetworkDictUpdates++;
    [_platformDict addValueToPayload:[SPUtilities getNetworkTechnology] forKey:kSPMobileNetworkTech];
    [_platformDict addValueToPayload:[SPUtilities getNetworkType]       forKey:kSPMobileNetworkType];
}

@end
