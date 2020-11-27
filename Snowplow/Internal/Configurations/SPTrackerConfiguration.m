//
//  SPTrackerConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerConfiguration.h"

@implementation SPTrackerConfiguration

- (instancetype)initWithNamespace:(NSString *)namespace appId:(NSString *)appId {
    if (self = [super init]) {
        self.namespace = namespace;
        self.appId = appId;

        self.devicePlatform = SPDevicePlatformMobile;
        self.base64Encoding = YES;

        self.sessionContext = YES;
        self.applicationContext = YES;
        self.screenContext = YES;
        self.screenViewAutotracking = YES;
        self.lifecycleAutotracking = YES;
        self.installAutotracking = YES;
        self.exceptionAutotracking = YES;
        self.diagnosticAutotracking = NO;
    }
    return self;
}

@end
