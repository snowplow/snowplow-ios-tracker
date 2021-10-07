//
//  SPDeviceInfoMonitor.m
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

#import "SPDeviceInfoMonitor.h"
#import "SPLogger.h"
#import "SPTrackerConstants.h"

#if SNOWPLOW_TARGET_IOS

#import <UIKit/UIScreen.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "SNOWReachability.h"
#include <sys/mount.h>
#if __has_include(<os/proc.h>)
#import <os/proc.h>
#define __HAS_OS_PROC_H__
#endif

#elif SNOWPLOW_TARGET_TV

#import <UIKit/UIScreen.h>

#elif SNOWPLOW_TARGET_WATCHOS

#import <WatchKit/WatchKit.h>

#endif

#include <sys/sysctl.h>

@implementation SPDeviceInfoMonitor

/*
 The IDFA can be retrieved using selectors rather than proper instance methods because
 the compiler would complain about the missing AdSupport framework.
 As stated in the header file, this only works if you have the AdSupport library in your project.
 If you have it and you want to use IDFA, add the compiler flag <code>SNOWPLOW_IDFA_ENABLED</code> to your build settings.
 If you haven't AdSupport framework in your project or SNOWPLOW_IDFA_ENABLED it's not set, it just compiles returning a nil advertisingIdentifier.
 
 Note that `advertisingIdentifier` returns a sequence of 0s when used in the simulator.
 Use a real device if you want a proper IDFA.
 */
- (NSString *) appleIdfa {
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
#ifdef SNOWPLOW_IDFA_ENABLED
    NSString *errorMsg = @"ASIdentifierManager not found. Please, add the AdSupport.framework if you want to use it.";
    Class identifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (!identifierManagerClass) {
        SPLogError(errorMsg);
        return nil;
    }

    SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
    if (![identifierManagerClass respondsToSelector:sharedManagerSelector]) {
        SPLogError(errorMsg);
        return nil;
    }

    id identifierManager = ((id (*)(id, SEL))[identifierManagerClass methodForSelector:sharedManagerSelector])(identifierManagerClass, sharedManagerSelector);
    
    if (@available(iOS 14.0, *)) {
        errorMsg = @"ATTrackingManager not found. Please, add the AppTrackingTransparency.framework if you want to use it.";
        Class trackingManagerClass = NSClassFromString(@"ATTrackingManager");
        if (!trackingManagerClass) {
            SPLogError(errorMsg);
            return nil;
        }
        
        SEL trackingStatusSelector = NSSelectorFromString(@"trackingAuthorizationStatus");
        if (![trackingManagerClass respondsToSelector:trackingStatusSelector]) {
            SPLogError(errorMsg);
            return nil;
        }
        
        //notDetermined = 0, restricted = 1, denied = 2, authorized = 3
        NSInteger authorizationStatus = ((NSInteger (*)(id, SEL))[trackingManagerClass methodForSelector:trackingStatusSelector])(trackingManagerClass, trackingStatusSelector);
        
        if (authorizationStatus != 3)  {
            SPLogDebug(@"The user didn't let tracking of IDFA. Authorization status is: %d", authorizationStatus);
            return nil;
        }
    } else {
        SEL isAdvertisingTrackingEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
        if (![identifierManager respondsToSelector:isAdvertisingTrackingEnabledSelector]) {
            SPLogError(errorMsg);
            return nil;
        }
        
        BOOL isAdvertisingTrackingEnabled = ((BOOL (*)(id, SEL))[identifierManager methodForSelector:isAdvertisingTrackingEnabledSelector])(identifierManager, isAdvertisingTrackingEnabledSelector);
        if (!isAdvertisingTrackingEnabled) {
            SPLogError(@"The user didn't let tracking of IDFA.");
            return nil;
        }
    }
    
    SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
    if (![identifierManager respondsToSelector:advertisingIdentifierSelector]) {
        SPLogError(@"ASIdentifierManager doesn't respond to selector `advertisingIdentifier`.");
        return nil;
    }

    NSUUID *uuid = ((NSUUID* (*)(id, SEL))[identifierManager methodForSelector:advertisingIdentifierSelector])(identifierManager, advertisingIdentifierSelector);
    return [uuid UUIDString];
#endif
#endif
    return nil;
}

- (NSString *) appleIdfv {
    NSString * idfv = nil;
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
#ifndef SNOWPLOW_NO_IDFV
    idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#endif
#endif
    return idfv;
}

- (NSString *) deviceVendor {
    return @"Apple Inc.";
}

- (NSString *) deviceModel {
    NSString *simulatorModel = [NSProcessInfo.processInfo.environment objectForKey: @"SIMULATOR_MODEL_IDENTIFIER"];
    if (simulatorModel) return simulatorModel;

    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) osVersion {
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
    return [[UIDevice currentDevice] systemVersion];
#elif SNOWPLOW_TARGET_WATCHOS
    return [[WKInterfaceDevice currentDevice] systemVersion];
#else
    SInt32 osxMajorVersion;
    SInt32 osxMinorVersion;
    SInt32 osxPatchFixVersion;
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSOperatingSystemVersion systemVersion = [info operatingSystemVersion];
    osxMajorVersion = (int)systemVersion.majorVersion;
    osxMinorVersion = (int)systemVersion.minorVersion;
    osxPatchFixVersion = (int)systemVersion.patchVersion;
    NSString *versionString = [NSString stringWithFormat:@"%d.%d.%d", osxMajorVersion,
                               osxMinorVersion, osxPatchFixVersion];
    return versionString;
#endif
}

- (NSString *) osType {
#if SNOWPLOW_TARGET_IOS
    return @"ios";
#elif SNOWPLOW_TARGET_TV
    return @"tvos";
#elif SNOWPLOW_TARGET_WATCHOS
    return @"watchos";
#else
    return @"osx";
#endif
}

- (NSString *) carrierName {
#if SNOWPLOW_TARGET_IOS
    CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier;
    if (@available(iOS 12.1, *)) {
        // `serviceSubscribersCellularProviders` has a bug in the iOS 12.0 so we use it from iOS 12.1
        NSString *carrierKey = [self carrierKey];
        if (!carrierKey) {
            return nil;
        }
        NSDictionary<NSString *,CTCarrier *> *services = [networkInfo serviceSubscriberCellularProviders];
        carrier = services[carrierKey];
    } else {
        carrier = [networkInfo subscriberCellularProvider];
    }
    return [carrier carrierName];
#endif
    return nil;
}

- (NSString *) networkTechnology {
#if SNOWPLOW_TARGET_IOS
    CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
    if (@available(iOS 12.1, *)) {
        // `serviceCurrentRadioAccessTechnology` has a bug in the iOS 12.0 so we use it from iOS 12.1
        NSString *carrierKey = [self carrierKey];
        if (!carrierKey) {
            return nil;
        }
        NSDictionary<NSString *, NSString *> *services = [networkInfo serviceCurrentRadioAccessTechnology];
        return services[carrierKey];
    } else {
        return [networkInfo currentRadioAccessTechnology];
    }
#endif
    return nil;
}

- (NSString *) carrierKey {
#if SNOWPLOW_TARGET_IOS
    if (@available(iOS 12.1, *)) {
        CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
        // `serviceSubscribersCellularProviders` has a bug in the iOS 12.0 so we use it from iOS 12.1
        NSDictionary<NSString *,CTCarrier *> *services = [networkInfo serviceSubscriberCellularProviders];
        NSArray<NSString *> *carrierKeys = services.allKeys;
        // From iOS 12, iPhones with eSIMs can return multiple carrier providers.
        // We can't prefer anyone of them so we track the first reported.
        return carrierKeys.firstObject;
    }
#endif
    return nil;
}

- (NSString *) networkType {
#if SNOWPLOW_TARGET_IOS
    SNOWNetworkStatus networkStatus = [SNOWReachability reachabilityForInternetConnection].networkStatus;
    switch (networkStatus) {
        case SNOWNetworkStatusOffline:
            return @"offline";
        case SNOWNetworkStatusWifi:
            return @"wifi";
        case SNOWNetworkStatusWWAN:
            return @"mobile";
    }
#endif
    return @"offline";
}

- (NSNumber *) batteryLevel {
#if SNOWPLOW_TARGET_IOS
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    if (batteryLevel != UIDeviceBatteryStateUnknown && batteryLevel >= 0) {
        return [[NSNumber alloc] initWithInt: (int) (batteryLevel * 100)];
    }
#endif
    return nil;
}

- (NSString *) batteryState {
#if SNOWPLOW_TARGET_IOS
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateCharging:
            return @"charging";
        case UIDeviceBatteryStateFull:
            return @"full";
        case UIDeviceBatteryStateUnplugged:
            return @"unplugged";
        default:
            return nil;
    }
#else
    return nil;
#endif
}

- (NSNumber *) isLowPowerModeEnabled {
#if SNOWPLOW_TARGET_IOS
    bool isEnabled = [[NSProcessInfo processInfo] isLowPowerModeEnabled];
    return [[NSNumber alloc] initWithBool:isEnabled];
#else
    return nil;
#endif
}

- (NSNumber *) physicalMemory {
    unsigned long long physicalMemory = [[NSProcessInfo processInfo] physicalMemory];
    return [[NSNumber alloc] initWithUnsignedLongLong:physicalMemory];
}

- (NSNumber *) appAvailableMemory {
#if SNOWPLOW_TARGET_IOS
#ifdef __HAS_OS_PROC_H__
    if (@available(iOS 13.0, *)) {
        unsigned long availableMemory = os_proc_available_memory();
        return [[NSNumber alloc] initWithUnsignedLong:availableMemory];
    }
#endif
#endif
    return nil;
}

- (NSNumber *) availableStorage {
#if SNOWPLOW_TARGET_IOS
    struct statfs tStats;
    if (statfs([NSHomeDirectory() UTF8String], &tStats) == 0) {
        return [[NSNumber alloc] initWithUnsignedLongLong: tStats.f_bavail * tStats.f_bsize];
    } else {
        SPLogError(@"Failed to read available storage size");
    }
#endif
    return nil;
}

- (NSNumber *) totalStorage {
#if SNOWPLOW_TARGET_IOS
    struct statfs tStats;
    if (statfs([NSHomeDirectory() UTF8String], &tStats) == 0) {
        return [[NSNumber alloc] initWithUnsignedLongLong: tStats.f_blocks * tStats.f_bsize];
    } else {
        SPLogError(@"Failed to read total storage size");
    }
#endif
    return nil;
}


@end
