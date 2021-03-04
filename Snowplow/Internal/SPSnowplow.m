//
//  SPSnowplow.m
//  Snowplow
//
//  Created by Alex Benini on 26/02/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPSnowplow.h"
#import "SPServiceProvider.h"

@implementation SPSnowplow

+ (id<SPTrackerController>)setupWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPHttpMethod)method namespace:(NSString *)namespace appId:(NSString *)appId {
    return [SPServiceProvider setupWithEndpoint:endpoint method:method namespace:namespace appId:appId];
}

+ (id<SPTrackerController>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration {
    return [SPServiceProvider setupWithNetwork:networkConfiguration tracker:trackerConfiguration];
}

+ (id<SPTrackerController>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    return [SPServiceProvider setupWithNetwork:networkConfiguration tracker:trackerConfiguration configurations:configurations];
}

@end
