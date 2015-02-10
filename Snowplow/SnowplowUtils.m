//
//  SnowplowUtils.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SnowplowUtils.h"
#import "OpenIDFA.h"

#if TARGET_OS_IPHONE

#import <UIKit/UIScreen.h>
#import <UIKit/UIDevice.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#else

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>

#endif

@implementation SnowplowUtils

+ (NSString *) getTimezone {
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    return [timeZone name];
}

+ (NSString *) getLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *) getPlatform {
    // There doesn't seem to be any reason to set any other value
    return @"mob";
}

+ (NSString *) getEventId {
    // Generates type 4 UUID
    return [[NSUUID UUID] UUIDString].lowercaseString;
}

+ (NSString *) getOpenIdfa {
    // See: https://github.com/ylechelle/OpenIDFA
    return [OpenIDFA sameDayOpenIDFA];
}

+ (NSString *) getAppleIdfa {
    NSString* ifa = nil;
#ifndef SNOWPLOW_NO_IFA && TARGET_OS_IPHONE
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifa = [uuid UUIDString];
    }
#endif
    return ifa;
}

+ (NSString *) getAppleIdfv {
#if TARGET_OS_IPHONE
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#else
    return @"";
#endif
}

+ (NSString *) getCarrierName {
#if TARGET_OS_IPHONE
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return [carrier carrierName];
#else
    return @"";
#endif
}

+ (int) getTransactionId {
    return arc4random() % (999999 - 100000+1) + 100000;
}

+ (double) getTimestamp {
    NSDate *time = [[NSDate alloc] init];
    return [time timeIntervalSince1970]*1000;
}

+ (NSString *) getResolution {
#if TARGET_OS_IPHONE
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
#else
    CGRect mainScreen = [[NSScreen mainScreen] frame];
    CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
#endif
    CGFloat screenWidth = mainScreen.size.width * screenScale;
    CGFloat screenHeight = mainScreen.size.height * screenScale;
    NSString *res = [NSString stringWithFormat:@"%.0fx%.0f", screenWidth, screenHeight];
    return res;
}

+ (NSString *) getViewPort {
    // This probably doesn't change as well
    return [self getResolution];
}

+ (NSString *) getDeviceVendor {
    return @"Apple Inc.";
}

+ (NSString *) getDeviceModel {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] model];
#else
    return @"";
#endif
}

+ (NSString *) getOSVersion {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] systemVersion];
#else
    long osxMajorVersion;
    long osxMinorVersion;
    long osxPatchFixVersion;
    NSProcessInfo *info = [NSProcessInfo processInfo];
    if ([info respondsToSelector:@selector(operatingSystemVersion)])
    {
        NSOperatingSystemVersion systemVersion = [info operatingSystemVersion];
        osxMajorVersion = (long)systemVersion.majorVersion;
        osxMinorVersion = (long)systemVersion.minorVersion;
        osxPatchFixVersion = (long)systemVersion.patchVersion;
    }
    else
    {
        Gestalt(gestaltSystemVersionMajor, &osxMajorVersion);
        Gestalt(gestaltSystemVersionMinor, &osxMinorVersion);
        Gestalt(gestaltSystemVersionBugFix, &osxPatchFixVersion);
    }
    NSString *versionString = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)osxMajorVersion,
                               (long)osxMinorVersion, (long)osxPatchFixVersion];
    return osxMinorVersion;
#endif
}

+ (NSString *) getOSType {
#if TARGET_OS_IPHONE
    return @"ios";
#else
    return @"osx";
#endif
}

+ (NSString *) getAppId {
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
