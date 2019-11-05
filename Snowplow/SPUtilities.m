//
//  SPUtils.m
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"
#include <sys/sysctl.h>

#if SNOWPLOW_TARGET_IOS

@import AdSupport;
#import "OpenIDFA.h"
#import <UIKit/UIScreen.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SnowplowTracker/SnowplowTracker-Swift.h>

#elif SNOWPLOW_TARGET_OSX

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>

#elif SNOWPLOW_TARGET_TV

@import AdSupport;
#import <UIKit/UIScreen.h>

#endif

@implementation SPUtilities

+ (NSString *) getTimezone {
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    return [timeZone name];
}

+ (NSString *) getLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *) getPlatform {
#if SNOWPLOW_TARGET_IOS
    return @"mob";
#else
    return @"pc";
#endif
}

+ (NSString *) getEventId {
    // Generates type 4 UUID
    return [[NSUUID UUID] UUIDString].lowercaseString;
}

+ (NSString *) getOpenIdfa {
    NSString * idfa = nil;
#if SNOWPLOW_TARGET_IOS
#ifndef SNOWPLOW_NO_OPENIDFA
    if (!SNOWPLOW_iOS_9_OR_LATER) {
        idfa = [OpenIDFA sameDayOpenIDFA];
    }
#endif
#endif
    return idfa;
}

+ (NSString *) getAppleIdfa {
    NSString* idfa = nil;
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
#ifndef SNOWPLOW_NO_IFA
    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSUUID *identifier = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        idfa = [identifier UUIDString];
    }
#endif
#endif
    return idfa;
}

+ (NSString *) getAppleIdfv {
    NSString * idfv = nil;
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
#ifndef SNOWPLOW_NO_IDFV
    idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#endif
#endif
    return idfv;
}

+ (NSString *) getCarrierName {
    NSString * carrierName = nil;
#if SNOWPLOW_TARGET_IOS
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    carrierName = [carrier carrierName];
#endif
    return carrierName;
}

+ (NSString *) getNetworkType {
    NSString * type = @"offline";
#if SNOWPLOW_TARGET_IOS
    type = [ReachabilityBridge connectionType];
#endif
    return type;
}

+ (NSString *) getNetworkTechnology {
    NSString * netTech = nil;
#if SNOWPLOW_TARGET_IOS
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    netTech = [netInfo currentRadioAccessTechnology];
#endif
    return netTech;
}

+ (int) getTransactionId {
    return arc4random() % (999999 - 100000+1) + 100000;
}

+ (NSNumber *) getTimestamp {
    NSDate *time = [[NSDate alloc] init];
    return @([time timeIntervalSince1970] * 1000);
}

+ (NSString *) getResolution {
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
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
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *) getOSVersion {
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
    return [[UIDevice currentDevice] systemVersion];
#else
    SInt32 osxMajorVersion;
    SInt32 osxMinorVersion;
    SInt32 osxPatchFixVersion;
    NSProcessInfo *info = [NSProcessInfo processInfo];
    if (@available(macOS 10.10, *)) {
        NSOperatingSystemVersion systemVersion = [info operatingSystemVersion];
        osxMajorVersion = (int)systemVersion.majorVersion;
        osxMinorVersion = (int)systemVersion.minorVersion;
        osxPatchFixVersion = (int)systemVersion.patchVersion;
    } else {
        // TODO eliminate this block once minimum version is OS X 10+
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        Gestalt(gestaltSystemVersionMajor, &osxMajorVersion);
        Gestalt(gestaltSystemVersionMinor, &osxMinorVersion);
        Gestalt(gestaltSystemVersionBugFix, &osxPatchFixVersion);
#pragma clang diagnostic pop
    }
    NSString *versionString = [NSString stringWithFormat:@"%d.%d.%d", osxMajorVersion,
                               osxMinorVersion, osxPatchFixVersion];
    return versionString;
#endif
}

+ (NSString *) getOSType {
#if SNOWPLOW_TARGET_IOS
    return @"ios";
#elif SNOWPLOW_TARGET_TV
    return @"tvos";
#else
    return @"osx";
#endif
}

+ (NSString *) getAppId {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)urlEncodeString:(NSString *)s {
    if (!s) {
        return @"";   
    }
    return (NSString *)CFBridgingRelease(
            CFURLCreateStringByAddingPercentEscapes(
                NULL, 
                (CFStringRef) s, 
                NULL, 
                (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+ (NSString *)urlEncodeDictionary:(NSDictionary *)d {
    NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:d.count];
    [d enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"%@=%@", [self urlEncodeString:key], [self urlEncodeString:[value description]]]];
    }];
    return [keyValuePairs componentsJoinedByString:@"&"];
}

+ (NSInteger) getByteSizeWithString:(NSString *)str {
    return [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL) isOnline {
    BOOL online = YES;
#if SNOWPLOW_TARGET_IOS
    online = [ReachabilityBridge isOnline];
#endif
    return online;
}

+ (void) checkArgument:(BOOL)argument withMessage:(NSString *)message {
    if (!argument) {
        SnowplowDLog(@"SPLog: Error occurred while checking argument: %@", message);
    }
}

#if SNOWPLOW_TARGET_IOS
+ (NSString *) getTriggerType:(UNNotificationTrigger *)trigger {
    NSMutableString * triggerType = [[NSMutableString alloc] initWithString:@"UNKNOWN"];
    NSString * triggerClass = NSStringFromClass([trigger class]);
    if ([triggerClass isEqualToString:@"UNTimeIntervalNotificationTrigger"]) {
        [triggerType setString:@"TIME_INTERVAL"];
    } else if ([triggerClass isEqualToString:@"UNCalendarNotificationTrigger"]) {
        [triggerType setString:@"CALENDAR"];
    } else if ([triggerClass isEqualToString:@"UNLocationNotificationTrigger"]) {
        [triggerType setString:@"LOCATION"];
    } else if ([triggerClass isEqualToString:@"UNPushNotificationTrigger"]) {
        [triggerType setString:@"PUSH"];
    }

    return (NSString *)triggerType;
}

+ (NSArray<NSDictionary *> *) convertAttachments:(NSArray<UNNotificationAttachment *> *)attachments {
    NSMutableArray<NSDictionary *> * converting = [[NSMutableArray alloc] init];
    NSMutableDictionary * newAttachment = [[NSMutableDictionary alloc] init];

    for (id attachment in attachments) {
        newAttachment[kSPPnAttachmentId] = [attachment valueForKey:@"identifier"];
        newAttachment[kSPPnAttachmentUrl] = [attachment valueForKey:@"URL"];
        newAttachment[kSPPnAttachmentType] = [attachment valueForKey:@"type"];
        [converting addObject: (NSDictionary *)[newAttachment copy]];
        [newAttachment removeAllObjects];
    }

    return (NSArray<NSDictionary *> *)[NSArray arrayWithArray:converting];
}
#endif

+ (NSDictionary *) removeNullValuesFromDictWithDict:(NSDictionary *)dict {
    NSMutableDictionary *cleanDictionary = [NSMutableDictionary dictionary];
    for (NSString * key in [dict allKeys]) {
        if (![[dict objectForKey:key] isKindOfClass:[NSNull class]]) {
            [cleanDictionary setObject:[dict objectForKey:key] forKey:key];
        }
    }
    return cleanDictionary;
}

+ (NSDictionary *) replaceHyphenatedKeysWithCamelcase:(NSDictionary *)dict{
    NSMutableDictionary * newDictionary = [[NSMutableDictionary alloc] init];
    for (NSString * key in dict) {
        if ([self string:key contains:@"-"]) {
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                newDictionary[[self camelcaseParsedKey:key]] = [self replaceHyphenatedKeysWithCamelcase:dict[key]];
            } else {
                newDictionary[[self camelcaseParsedKey:key]] = dict[key];
            }
        } else {
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                newDictionary[key] = [self replaceHyphenatedKeysWithCamelcase:dict[key]];
            } else {
                newDictionary[key] = dict[key];
            }
        }
    }
    
    return [[NSDictionary alloc] initWithDictionary:newDictionary copyItems:YES];
}

+ (BOOL) string:(NSString *)string contains:(NSString *)subString {
    if (!subString) return false;
    if (@available(macOS 10.10, *)) {
        return [string containsString:subString];
    } else {
        return ([string rangeOfString:subString].location != NSNotFound);
    }
}

+ (NSString *) camelcaseParsedKey:(NSString *)key {
    NSScanner * scanner = [[NSScanner alloc] initWithString:key];
    NSMutableArray * words = [[NSMutableArray alloc] init];
    NSString * scannedWord = [[NSString alloc] init];

    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"-" intoString:&scannedWord];
        [words addObject:scannedWord];
        NSLog(@"scanned word: %@", scannedWord);
        [scanner scanString:@"-" intoString:nil];
    }

    NSLog(@"%@", words);
    if ([words count] == 0) {
        return @"";
    } else if ([words count] == 1) {
        return [[NSString alloc] initWithString:[words[0] lowercaseString]];
    } else {
        NSMutableString * camelcaseKey = [[NSMutableString alloc] initWithString:[words[0] lowercaseString]];
        NSRange range;
        range.length = words.count-1;
        range.location = 1;
        for (NSString * word in [words subarrayWithRange:range]) {
            [camelcaseKey appendString:[word capitalizedString]];
        }
        return camelcaseKey;
    }
}

+ (NSString *) validateString:(NSString *)aString {
    if (!aString | ([aString length] == 0)) {
        return nil;
    }
    return aString;
}

+ (SPSelfDescribingJson *) getScreenContextWithScreenState:(SPScreenState *)screenState {
    SPPayload * contextPayload = [screenState getValidPayload];
    if (contextPayload) {
        return [[SPSelfDescribingJson alloc] initWithSchema:kSPScreenContextSchema andPayload:contextPayload];
    } else {
    	return nil;
    }
}

+ (SPSelfDescribingJson *) getApplicationContext {
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    return [self getApplicationContextWithVersion:version andBuild:build];
}

+ (SPSelfDescribingJson *) getApplicationContextWithVersion:(NSString *)version andBuild:(NSString *)build {
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:build forKey:kSPApplicationBuild];
    [payload addValueToPayload:version forKey:kSPApplicationVersion];
    if (payload != nil && [[payload getAsDictionary] count] > 0) {
        return [[SPSelfDescribingJson alloc] initWithSchema:kSPApplicationContextSchema andPayload:payload];
    } else {
        return nil;
    }
}

+ (NSString *) getAppVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *) getAppBuild {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

@end
