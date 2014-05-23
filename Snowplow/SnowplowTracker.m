//
//  SnowplowTracker.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SnowplowTracker.h"
#import "SnowplowPayload.h"
#import "SnowplowUtils.h"

@implementation SnowplowTracker

NSString * const kSnowplowVendor = @"com.snowplowanalytics.snowplow";
Boolean const kDefaultEncodeBase64 = true;
NSString * const kVersion = @"ios-0.1";

- (id) init {
    self = [super init];
    if(self) {
        self.trackerNamespace = nil;
        self.base64Encoded = true;
        self.collector = nil;
        self.standardData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             kVersion, @"tv", nil];
    }
    return self;
}

- (id) initUsingNamespace:(NSString *)namespace
                    appId:(NSString *)appId
            base64Encoded:(Boolean)encoded
                collector:(SnowplowRequest *)collector {
    self = [super init];
    if(self) {
        self.trackerNamespace = namespace;
        self.base64Encoded = encoded;
        self.collector = collector;
        self.standardData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             kVersion, @"tv",
                             namespace, @"tna",
                             appId, @"aid", nil];
    }
    return self;
}

- (void) setCollector:(SnowplowRequest *)collector {
    self.collector = collector;
}

- (void) setNamespace:(NSString *)trackerNamespace {
    self.trackerNamespace = trackerNamespace;
}

- (void) setAppId:(NSString *)appId {
    self.appId = appId;
}

- (void) setUserId:(NSString *)userId {
    [self.standardData setObject:userId forKey:@"uid"];
}

- (void) setSubject:(SnowplowPayload *)payload {
    NSString *timestampStr = [NSString stringWithFormat:@"%f", [SnowplowUtils getTimestamp]];
    
    [payload addValueToPayload:[SnowplowUtils getPlatform] withKey:@"p"];
    [payload addValueToPayload:[SnowplowUtils getResolution] withKey:@"res"];
    [payload addValueToPayload:[SnowplowUtils getViewPort] withKey:@"vp"];
    [payload addValueToPayload:[SnowplowUtils getEventId] withKey:@"eid"];
    [payload addValueToPayload:[SnowplowUtils getLanguage] withKey:@"lang"];
    [payload addValueToPayload:timestampStr withKey:@"dtm"];
    // Commented out, until issue #25 is resolved
    // [payload addValueToPayload:[util getTransactionId] withKey:@"tid"];
}

- (void) addTracker:(SnowplowPayload *)event {
    
}

@end
