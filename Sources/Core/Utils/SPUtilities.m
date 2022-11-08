//
//  SPUtils.m
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  License: Apache License Version 2.0
//

#import "SPTrackerConstants.h"
#import "SPDevicePlatform.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"
#import "SPLogger.h"
#import "SPDeviceInfoMonitor.h"

#if SNOWPLOW_TARGET_IOS

#import <UIKit/UIScreen.h>

#elif SNOWPLOW_TARGET_OSX

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>

#elif SNOWPLOW_TARGET_TV

#import <UIKit/UIScreen.h>

#elif SNOWPLOW_TARGET_WATCHOS

#import <WatchKit/WatchKit.h>

#endif

@implementation SPUtilities

+ (NSString *) getTimezone {
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    return [timeZone name];
}

+ (NSString *) getLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (SPDevicePlatform) getPlatform {
#if SNOWPLOW_TARGET_IOS
    return SPDevicePlatformMobile;
#else
    return SPDevicePlatformDesktop;
#endif
}

+ (NSString *) getUUIDString {
    // Generates type 4 UUID
    return [[NSUUID UUID] UUIDString].lowercaseString;
}

+ (bool ) isUUIDString:(nonnull NSString *)uuidString {
    return [[NSUUID alloc] initWithUUIDString:uuidString] != nil;
}

+ (NSNumber *) getTimestamp {
    NSDate *time = [[NSDate alloc] init];
    return @([time timeIntervalSince1970] * 1000);
}

+ (NSString *) timestampToISOString:(long long)timestamp {
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000.0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:eventDate];
}

+ (NSString *) getResolution {
#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
#elif SNOWPLOW_TARGET_WATCHOS
    CGRect mainScreen = [[WKInterfaceDevice currentDevice] screenBounds];
    CGFloat screenScale = [[WKInterfaceDevice currentDevice] screenScale];
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

+ (NSString *) getAppId {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)urlEncodeString:(NSString *)string {
    if (!string) {
        return @"";   
    }
    NSMutableCharacterSet *allowedCharSet = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [allowedCharSet removeCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharSet];
}

+ (NSString *)urlEncodeDictionary:(NSDictionary *)d {
    NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:d.count];
    [d enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"%@=%@", [self urlEncodeString:key], [self urlEncodeString:[value description]]]];
    }];
    return [keyValuePairs componentsJoinedByString:@"&"];
}

+ (void) checkArgument:(BOOL)argument withMessage:(NSString *)message {
    if (!argument) {
        SPLogDebug(@"Error occurred while checking argument: %@", message);
         #if DEBUG
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
         #endif
    }
}

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
        SPLogVerbose(@"scanned word: %@", scannedWord);
        [scanner scanString:@"-" intoString:nil];
    }

    SPLogVerbose(@"%@", words);
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
