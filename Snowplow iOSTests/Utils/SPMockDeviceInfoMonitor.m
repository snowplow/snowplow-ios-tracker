//
//  SPMockDeviceInfoMonitor.m
//  Snowplow-iOSTests
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

#import "SPMockDeviceInfoMonitor.h"

@implementation SPMockDeviceInfoMonitor

- (instancetype) init {
    if (self = [super init]) {
        self.methodAccessCounts = [[NSMutableDictionary alloc] init];
        self.customAppleIdfa = @"appleIdfa";
        self.customAppleIdfv = @"appleIdfv";
    }
    return self;
}

- (NSString *) appleIdfa {
    [self increaseMethodAccessCount:@"appleIdfa"];
    return self.customAppleIdfa;
}

- (NSString *) appleIdfv {
    [self increaseMethodAccessCount:@"appleIdfv"];
    return self.customAppleIdfv;
}

- (NSString *) deviceVendor {
    [self increaseMethodAccessCount:@"deviceVendor"];
    return @"Apple Inc.";
}

- (NSString *) deviceModel {
    [self increaseMethodAccessCount:@"deviceModel"];
    return @"deviceModel";
}

- (NSString *) osVersion {
    [self increaseMethodAccessCount:@"osVersion"];
    return @"13.0.0";
}

- (NSString *) osType {
    [self increaseMethodAccessCount:@"osType"];
    return @"ios";
}

- (NSString *) carrierName {
    [self increaseMethodAccessCount:@"carrierName"];
    return @"att";
}

- (NSString *) networkTechnology {
    [self increaseMethodAccessCount:@"networkTechnology"];
    return @"3g";
}

- (NSString *) networkType {
    [self increaseMethodAccessCount:@"networkType"];
    return @"wifi";
}

- (NSNumber *) batteryLevel {
    [self increaseMethodAccessCount:@"batteryLevel"];
    return @20;
}

- (NSString *) batteryState {
    [self increaseMethodAccessCount:@"batteryState"];
    return @"charging";
}

- (NSNumber *) isLowPowerModeEnabled {
    [self increaseMethodAccessCount:@"isLowPowerModeEnabled"];
    return @NO;
}

- (NSNumber *) physicalMemory {
    [self increaseMethodAccessCount:@"physicalMemory"];
    return @100000L;
}

- (NSNumber *) appAvailableMemory {
    [self increaseMethodAccessCount:@"appAvailableMemory"];
    return @1000L;
}

- (NSNumber *) availableStorage {
    [self increaseMethodAccessCount:@"availableStorage"];
    return @9000L;
}

- (NSNumber *) totalStorage {
    [self increaseMethodAccessCount:@"totalStorage"];
    return @900000L;
}

- (int) accessCount:(NSString *) method {
    NSNumber *count = [self.methodAccessCounts valueForKey:method] ?: @0;
    return [count intValue];
}

- (void) increaseMethodAccessCount:(NSString *) method {
    [self.methodAccessCounts setValue:[NSNumber numberWithInt:[self accessCount:method] + 1] forKey:method];
}

@end
