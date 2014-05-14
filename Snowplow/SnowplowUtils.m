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

@implementation SnowplowUtils

- (NSString *) getTimezone {
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    return [timeZone name];
}

- (NSString *) getLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *) getPlatform {
    // There doesn't seem to be any reason to set any other value
    return @"mob";
}

- (NSString *) getEventId {
    // Generates type 4 UUID
    return [[NSUUID UUID] UUIDString];
}

- (NSDictionary *) getResolution {
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = mainScreen.size.width;
    CGFloat screenHeight = mainScreen.size.height;
    NSDictionary *res = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSString stringWithFormat:@"%.0f", screenWidth], @"width",
                         [NSString stringWithFormat:@"%.0f", screenHeight], @"height", nil];
    return res;
}

- (NSDictionary *) getViewPort {
    // This probably doesn't change as well
    return [self getResolution];
}

@end
