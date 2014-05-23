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
    [payload addValueToPayload:[SnowplowUtils getPlatform] withKey:@"p"];
    [payload addValueToPayload:[SnowplowUtils getResolution] withKey:@"res"];
    [payload addValueToPayload:[SnowplowUtils getViewPort] withKey:@"vp"];
    [payload addValueToPayload:[SnowplowUtils getEventId] withKey:@"eid"];
    [payload addValueToPayload:[SnowplowUtils getLanguage] withKey:@"lang"];
    [payload addValueToPayload:[NSNumber numberWithDouble:[SnowplowUtils getTimestamp]] withKey:@"dtm"];
    // Commented out, until issue #25 is resolved
    // [payload addValueToPayload:[util getTransactionId] withKey:@"tid"];
}

- (void) addTracker:(SnowplowPayload *)event {
    [self.collector addPayloadToBuffer:event];
}

- (void) trackPageView:(NSString *)page_url
                 title:(NSString *)page_title
              referrer:(NSString *)referrer
               context:(NSDictionary *)schema
             timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self setSubject:pb];
    [pb addValueToPayload:@"pv"      withKey:@"e"];
    [pb addValueToPayload:page_url   withKey:@"url"];
    [pb addValueToPayload:page_title withKey:@"page"];
    [pb addValueToPayload:referrer   withKey:@"refr"];

    [pb addDictionaryToPayload:schema
                 base64Encoded:self.base64Encoded
               typeWhenEncoded:@"cx"
            typeWhenNotEncoded:@"co"];

    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] withKey:@"dtm"];
    
    [self addTracker:pb];
}

- (void) trackEcommerceTransactionItem:(NSString *)order_id
                                   sku:(NSString *)sku
                                  name:(NSString *)name
                              category:(NSString *)category
                                 price:(float)price
                              quantity:(int)quantity
                              currency:(NSString *)currency
                               context:(NSDictionary *)schema
                             timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self setSubject:pb];

    [pb addValueToPayload:@"ti" withKey:@"e"];
    [pb addValueToPayload:order_id withKey:@"ti_id"];
    [pb addValueToPayload:sku withKey:@"ti_sk"];
    [pb addValueToPayload:name withKey:@"ti_nm"];
    [pb addValueToPayload:category withKey:@"ti_ca"];
    [pb addValueToPayload:[NSNumber numberWithFloat:price] withKey:@"ti_pr"];
    [pb addValueToPayload:[NSNumber numberWithInt:quantity] withKey:@"ti_qu"];
    [pb addValueToPayload:currency withKey:@"ti_cu"];
    
    [pb addDictionaryToPayload:schema
                 base64Encoded:self.base64Encoded
               typeWhenEncoded:@"cx"
            typeWhenNotEncoded:@"co"];

    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] withKey:@"dtm"];
    
    [self addTracker:pb];
}

- (void) trackEcommerceTransaction:(NSString *)order_id
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSDictionary *)items
                           context:(NSDictionary *)context {
    //TODO
}

@end
