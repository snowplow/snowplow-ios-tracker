//
//  SPDevicePlatform.m
//  Snowplow
//
//  Created by Alex Benini on 18/12/2019.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SPDevicePlatform.h"

NSString *SPDevicePlatformToString(SPDevicePlatform devicePlatform) {
    switch (devicePlatform) {
        case SPDevicePlatformWeb: return @"web";
        case SPDevicePlatformMobile: return @"mob";
        case SPDevicePlatformDesktop: return @"pc";
        case SPDevicePlatformServerSideApp: return @"srv";
        case SPDevicePlatformGeneral: return @"app";
        case SPDevicePlatformConnectedTV: return @"tv";
        case SPDevicePlatformGameConsole: return @"cnsl";
        case SPDevicePlatformInternetOfThings: return @"iot";
        default: return nil;
    }
}
