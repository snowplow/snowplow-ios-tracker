//
//  SPDevicePlatform.h
//  Snowplow
//
//  Created by Alex Benini on 18/12/2019.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(NSUInteger, SPDevicePlatform) {
    SPDevicePlatformWeb = 0,
    SPDevicePlatformMobile,
    SPDevicePlatformDesktop,
    SPDevicePlatformServerSideApp,
    SPDevicePlatformGeneral,
    SPDevicePlatformConnectedTV,
    SPDevicePlatformGameConsole,
    SPDevicePlatformInternetOfThings,
};

NSString *SPDevicePlatformToString(SPDevicePlatform devicePlatform);
