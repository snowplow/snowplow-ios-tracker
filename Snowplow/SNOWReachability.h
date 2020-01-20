//
//  SNOWReachability.h
//  Snowplow
//
//  Created by Alex Benini on 11/12/2019.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSUInteger, SNOWNetworkStatus) {
    SNOWNetworkStatusOffline,
    SNOWNetworkStatusWifi,
    SNOWNetworkStatusWWAN,
};

@interface SNOWReachability: NSObject

@property (nonatomic,assign) SNOWNetworkStatus networkStatus;

+ (instancetype)reachabilityForInternetConnection;

@end
