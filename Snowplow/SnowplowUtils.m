//
//  SnowplowUtils.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-13.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
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
                         @"width", [NSString stringWithFormat:@"%.0f", screenWidth],
                         @"height", [NSString stringWithFormat:@"%.0f", screenHeight],nil];
    return res;
}

- (NSDictionary *) getViewPort {
    // This probably doesn't change as well
    return [self getResolution];
}

@end
