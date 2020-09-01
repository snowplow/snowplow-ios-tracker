//
//  SPInstallTracker.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Michael Hadam
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPInstallTracker.h"
#import "SPUtilities.h"
#import "Snowplow.h"

@implementation SPInstallTracker

- (id) init {
    if (self = [super init]) {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:kSPInstalledBefore] == nil) {
            // mark the install if there's no value in userDefaults
            [userDefaults setObject:@YES forKey:kSPInstalledBefore];
            [userDefaults setObject:[SPUtilities getTimestamp] forKey:kSPInstallTimestamp];
            // since the value was missing in userDefaults, we're assuming this is a new install
            self.isNewInstall = YES;
        } else {
            // if there's an object in standardUserDefaults - someone has been there!
            self.isNewInstall = NO;
        }
        return self;
    }
    return nil;
}

- (NSNumber *) getPreviousInstallTimestamp {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kSPInstallTimestamp];
}

- (void) clearPreviousInstallTimestamp {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kSPInstallTimestamp];
}

- (void) saveBuildAndVersion {
    NSString * build = [SPUtilities getAppBuild];
    NSString * version = [SPUtilities getAppVersion];
    if (build && version) {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:build forKey:kSPPreviousInstallBuild];
        [userDefaults setObject:version forKey:kSPPreviousInstallVersion];
    }
}

@end
