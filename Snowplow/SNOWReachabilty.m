//
//  SNOWReachabilty.m
//  Snowplow
//
//  Created by Alex Benini on 11/12/2019.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>

#import "SNOWReachability.h"

#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
#if kShouldPrintReachabilityFlags
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
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
    BOOL isWWAN = (flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN;
    
    if (!isReachable) {
        return SNOWNetworkStatusOffline;
    }

    if (isWWAN) {
        return SNOWNetworkStatusWWAN;
    }

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
