//
//  SPPlatformContext.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPPlatformContext.h"
#import "SPPayload.h"
#import "SPTrackerConstants.h"
#import "SPDeviceInfoMonitor.h"

@interface SPPlatformContext ()

@property (strong, nonatomic) SPPayload *platformDict;
@property (strong, nonatomic, readonly) SPDeviceInfoMonitor *deviceInfoMonitor;
@property (nonatomic, readonly) NSTimeInterval mobileDictUpdateFrequency;
@property (nonatomic, readonly) NSTimeInterval networkDictUpdateFrequency;
@property (nonatomic) NSTimeInterval lastUpdatedEphemeralMobileDict;
@property (nonatomic) NSTimeInterval lastUpdatedEphemeralNetworkDict;

@end

@implementation SPPlatformContext

- (instancetype) init {
    return [self initWithMobileDictUpdateFrequency:0.1 networkDictUpdateFrequency:10.0 deviceInfoMonitor:[[SPDeviceInfoMonitor alloc] init]];
}

- (instancetype) initWithMobileDictUpdateFrequency:(NSTimeInterval)mobileDictUpdateFrequency networkDictUpdateFrequency:(NSTimeInterval)networkDictUpdateFrequency {
    return [self initWithMobileDictUpdateFrequency:mobileDictUpdateFrequency networkDictUpdateFrequency:networkDictUpdateFrequency deviceInfoMonitor:[[SPDeviceInfoMonitor alloc] init]];
}

- (instancetype) initWithMobileDictUpdateFrequency:(NSTimeInterval)mobileDictUpdateFrequency networkDictUpdateFrequency:(NSTimeInterval)networkDictUpdateFrequency deviceInfoMonitor:(SPDeviceInfoMonitor *)deviceInfoMonitor {
    if (self = [super init]) {
        _mobileDictUpdateFrequency = mobileDictUpdateFrequency;
        _networkDictUpdateFrequency = networkDictUpdateFrequency;
        _deviceInfoMonitor = deviceInfoMonitor;
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
        if (now - self.lastUpdatedEphemeralMobileDict >= self.mobileDictUpdateFrequency) {
            [self setEphemeralMobileDict];
        }
        if (now - self.lastUpdatedEphemeralNetworkDict >= self.networkDictUpdateFrequency) {
            [self setEphemeralNetworkDict];
        }
    }
#endif
    return self.platformDict;
}

// MARK: - Private methods

- (void) setPlatformDict {
    self.platformDict = [[SPPayload alloc] init];
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor osType]       forKey:kSPPlatformOsType];
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor osVersion]    forKey:kSPPlatformOsVersion];
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor deviceVendor] forKey:kSPPlatformDeviceManu];
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor deviceModel]  forKey:kSPPlatformDeviceModel];
    
#if SNOWPLOW_TARGET_IOS
    [self setMobileDict];
#endif
}

- (void) setMobileDict {
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor carrierName]           forKey:kSPMobileCarrier];
    [self.platformDict addNumericValueToPayload:[self.deviceInfoMonitor totalStorage]   forKey:kSPMobileTotalStorage];
    [self.platformDict addNumericValueToPayload:[self.deviceInfoMonitor physicalMemory] forKey:kSPMobilePhysicalMemory];
    
    [self setEphemeralMobileDict];
    [self setEphemeralNetworkDict];
}

- (void) setEphemeralMobileDict {
    self.lastUpdatedEphemeralMobileDict = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *currentDict = [self.platformDict getAsDictionary];
    if ([currentDict valueForKey:kSPMobileAppleIdfa] == nil) {
        [self.platformDict addValueToPayload:[self.deviceInfoMonitor appleIdfa] forKey:kSPMobileAppleIdfa];
    }
    if ([currentDict valueForKey:kSPMobileAppleIdfv] == nil) {
        [self.platformDict addValueToPayload:[self.deviceInfoMonitor appleIdfv] forKey:kSPMobileAppleIdfv];
    }
    
    [self.platformDict addNumericValueToPayload:[self.deviceInfoMonitor batteryLevel]          forKey:kSPMobileBatteryLevel];
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor batteryState]                 forKey:kSPMobileBatteryState];
    [self.platformDict addNumericValueToPayload:[self.deviceInfoMonitor isLowPowerModeEnabled] forKey:kSPMobileLowPowerMode];
    [self.platformDict addNumericValueToPayload:[self.deviceInfoMonitor availableStorage]      forKey:kSPMobileAvailableStorage];
    [self.platformDict addNumericValueToPayload:[self.deviceInfoMonitor appAvailableMemory]    forKey:kSPMobileAppAvailableMemory];
}

- (void) setEphemeralNetworkDict {
    self.lastUpdatedEphemeralNetworkDict = [[NSDate date] timeIntervalSince1970];
    
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor networkTechnology] forKey:kSPMobileNetworkTech];
    [self.platformDict addValueToPayload:[self.deviceInfoMonitor networkType]       forKey:kSPMobileNetworkType];
}


@end
