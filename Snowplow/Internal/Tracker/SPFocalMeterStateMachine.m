//
//  SPFocalMeterStateMachine.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPFocalMeterStateMachine.h"
#import "SPTrackerEvent.h"
#import "SPLogger.h"

@interface SPFocalMeterStateMachine ()

@property (nullable, nonatomic) NSString *lastUserId;
@property (nonnull, nonatomic) NSString *endpoint;

@end

@implementation SPFocalMeterStateMachine

- (instancetype)initWithEndpoint:(NSString *)endpoint {
    if (self = [super init]) {
        self.endpoint = endpoint;
    }
    return self;
}

- (NSArray<NSString *> *)subscribedEventSchemasForTransitions {
    return @[];
}

- (NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration {
    return @[@"*"];
}

- (NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating {
    return @[];
}

- (id<SPState>)transitionFromEvent:(SPEvent *)event state:(id<SPState>)currentState {
    return nil;
}

/*
 Note: this is a workaround that abuses the entitiesFromEvent:state: function to check the
 client session context entity for changes. We should provide a dedicated endpoint for
 this purpose in future versions.
 */
- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if ([event isKindOfClass:SPTrackerEvent.class]) {
        SPTrackerEvent *trackerEvent = (SPTrackerEvent *)event;
        NSMutableArray<SPSelfDescribingJson *> *contexts = trackerEvent.contexts;
        for (SPSelfDescribingJson *entity in contexts) {
            if ([[entity schema] isEqualToString:kSPSessionContextSchema]) {
                NSDictionary *data = (NSDictionary *)[entity data];
                NSString *userId = (NSString *)[data valueForKey:kSPSessionUserId];
                if ([self shouldUpdate:userId]) {
                    [self makeRequest:userId];
                }
            }
        }
    }
    
    return nil;
}

- (NSDictionary<NSString *,NSObject *> *)payloadValuesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    return nil;
}

- (BOOL)shouldUpdate:(NSString *)newUserId {
    @synchronized (self) {
        if (newUserId != nil && (_lastUserId == nil || ![newUserId isEqualToString:_lastUserId])) {
            _lastUserId = newUserId;
            return true;
        }
        return false;
    }
}

- (void)makeRequest:(NSString *)userId {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:self.endpoint];
        components.queryItems = @[
            [[NSURLQueryItem alloc] initWithName:@"vendor" value:@"snowplow"],
            [[NSURLQueryItem alloc] initWithName:@"cs_fpid" value:userId],
            [[NSURLQueryItem alloc] initWithName:@"c12" value:@"not_set"]
        ];
        
        NSURL *url = [components URL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"GET"];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                         completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
            BOOL isSuccessful = [httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300;
            if (isSuccessful) {
                SPLogDebug(@"Request to Kantar endpoint sent with user ID: %@", userId);
            } else {
                SPLogError(@"Request to Kantar endpoint was not successful");
            }
        }] resume];
    });
}

@end
