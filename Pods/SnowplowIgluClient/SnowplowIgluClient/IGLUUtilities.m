//
//  IGLUUtilities.m
//  SnowplowIgluClient
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

#import "IGLUConstants.h"
#import "IGLUUtilities.h"

@implementation IGLUUtilities

+ (NSDictionary *)parseToJsonWithString:(NSString *)json {
    @try {
        NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:objectData options:0 error:nil];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (NSString *)getStringWithUrlPath:(NSString *)urlPath {
    NSURL  *url = [NSURL URLWithString:urlPath];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

+ (NSString *)getStringWithFilePath:(NSString *)filePath
                             andDirectory:(NSString *)directory
                                andBundle:(NSBundle *)mainBundle {
    NSString * path = [mainBundle pathForResource:filePath ofType:nil inDirectory:directory];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str isEqual: @""]) {
        return nil;
    }
    return str;
}

+ (NSDictionary *)getJsonAsDictionaryWithFilePath:(NSString *)filePath
                                     andDirectory:(NSString *)directory
                                        andBundle:(NSBundle *)mainBundle {
    NSString * path = [mainBundle pathForResource:filePath ofType:nil inDirectory:directory];
    @try {
        NSData * data = [NSData dataWithContentsOfFile:path];
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (void) checkArgument:(BOOL)argument withMessage:(NSString *)message {
    if (!argument) {
        [NSException raise:@"RuntimeException" format:@"%@", message];
    }
}

@end
