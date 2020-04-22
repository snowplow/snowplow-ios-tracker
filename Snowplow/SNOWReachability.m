//
//  SNOWReachabilty.m
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
//  Authors: Alex Benini
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import <sys/socket.h>
#import <netinet/in.h>

#import "SNOWReachability.h"

#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
#if kShouldPrintReachabilityFlags
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
#if SNOWPLOW_TARGET_IOS
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
          '-',
#endif
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}

#pragma mark - SNOWReachability implementation

@implementation SNOWReachability {
    SCNetworkReachabilityRef _reachabilityRef;
}

@synthesize networkStatus;

+ (instancetype) reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *) &zeroAddress);
    if (reachability == NULL) return NULL;
    
    SNOWReachability* returnValue = [[self alloc] init];
    if (returnValue == NULL) {
        CFRelease(reachability);
        return NULL;
    }
    
    returnValue->_reachabilityRef = reachability;
    return returnValue;
}

- (SNOWNetworkStatus) networkStatus {
    NSAssert(_reachabilityRef != NULL, @"currentReachabilityStatus called with NULL SCNetworkReachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return SNOWNetworkStatusOffline;
    }
    return [self reachabilityStatusForFlags:flags];
}

# pragma mark - Private methods

- (SNOWNetworkStatus) reachabilityStatusForFlags:(SCNetworkReachabilityFlags)flags {
    PrintReachabilityFlags(flags, "reachabilityStatusForFlags");
    BOOL isReachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    BOOL isConnectionRequired = (flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0;
    BOOL isOnDemand = (flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0;
    BOOL isOnTraffic = (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0;
    BOOL isInterventionRequired = (flags & kSCNetworkReachabilityFlagsInterventionRequired) != 0;
    
    if (!isReachable) {
        return SNOWNetworkStatusOffline;
    }

#if SNOWPLOW_TARGET_IOS
    BOOL isWWAN = (flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN;
    if (isWWAN) {
        return SNOWNetworkStatusWWAN;
    }
#endif

    SNOWNetworkStatus returnValue = SNOWNetworkStatusOffline;
    if (!isConnectionRequired) {
        // If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi
        returnValue = SNOWNetworkStatusWifi;
    }
    if (isOnDemand || isOnTraffic) {
        //... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
        if (!isInterventionRequired) {
            //... and no [user] intervention is needed...
            returnValue = SNOWNetworkStatusWifi;
        }
    }
    return returnValue;
}

@end
