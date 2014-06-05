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
        [self setSchemaTag:@"jsonschema"];
        _trackerNamespace = nil;
        _base64Encoded = true;
        _collector = nil;
        _standardData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             kVersion, @"tv", nil];
    }
    return self;
}

- (id) initUsingCollector:(SnowplowRequest *)collector
                    appId:(NSString *)appId
            base64Encoded:(Boolean)encoded
                namespace:(NSString *)namespace_ {
    self = [super init];
    if(self) {
        [self setSchemaTag:@"jsonschema"];
        _trackerNamespace = namespace_;
        _base64Encoded = encoded;
        _collector = collector;
        _standardData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             kVersion, @"tv",
                             namespace_, @"tna",
                             appId, @"aid", nil];
    }
    return self;
}

- (void) setCollector:(SnowplowRequest *)collector {
    _collector = collector;
}

- (void) setNamespace:(NSString *)trackerNamespace {
    _trackerNamespace = trackerNamespace;
}

- (void) setAppId:(NSString *)appId {
    _appId = appId;
}

- (void) setUserId:(NSString *)userId {
    [self.standardData setObject:userId forKey:@"uid"];
}

- (void) setSchemaTag:(NSString *)schema {
    _schemaTag = schema;
    _contextSchema = [NSString stringWithFormat:@"iglu:com.snowplowanalytics/contexts/%@/1-0-0", schema];
    _unstructedEventSchema = [NSString stringWithFormat:@"iglu:com.snowplowanalytics/unstruct_event/%@/1-0-0", schema];
}

- (void) setContext:(SnowplowPayload *)pb
            context:(NSDictionary *)context {
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.contextSchema, @"schema",
                              context, @"data", nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:self.base64Encoded
               typeWhenEncoded:@"cx"
            typeWhenNotEncoded:@"co"];
}

- (void) addStandardValuesToPayload:(SnowplowPayload *)payload {
    [payload addDictionaryToPayload:self.standardData];
    [payload addValueToPayload:[SnowplowUtils getPlatform] withKey:@"p"];
    [payload addValueToPayload:[SnowplowUtils getResolution] withKey:@"res"];
    [payload addValueToPayload:[SnowplowUtils getViewPort] withKey:@"vp"];
    [payload addValueToPayload:[SnowplowUtils getEventId] withKey:@"eid"];
    [payload addValueToPayload:[SnowplowUtils getLanguage] withKey:@"lang"];
    [payload addValueToPayload:[NSNumber numberWithDouble:[SnowplowUtils getTimestamp]] withKey:@"dtm"];
}

- (void) addTracker:(SnowplowPayload *)event {
    [self.collector addPayloadToBuffer:event];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSDictionary *)context
                    timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    
    [pb addValueToPayload:@"se" withKey:@"e"];
    [pb addValueToPayload:category withKey:@"se_ca"];
    [pb addValueToPayload:action withKey:@"se_ac"];
    [pb addValueToPayload:label withKey:@"se_la"];
    [pb addValueToPayload:property withKey:@"se_pr"];
    [pb addValueToPayload:[NSNumber numberWithFloat:value] withKey:@"se_va"];
    
    if (timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] withKey:@"dtm"];

    [self addTracker:pb];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSDictionary *)context
                      timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    
    [pb addValueToPayload:@"ue" withKey:@"e"];

    // Creates similar envelop as in setContext with but different encoding keys
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.contextSchema, @"schema",
                          context, @"data", nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:self.base64Encoded
               typeWhenEncoded:@"ue_px"
            typeWhenNotEncoded:@"ue_pr"];
    
    [self addTracker:pb];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSDictionary *)context
             timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];
    
    [pb addValueToPayload:@"pv"      withKey:@"e"];
    [pb addValueToPayload:pageUrl   withKey:@"url"];
    [pb addValueToPayload:pageTitle withKey:@"page"];
    [pb addValueToPayload:referrer   withKey:@"refr"];

    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] withKey:@"dtm"];
    
    [self addTracker:pb];
}

- (void) trackEcommerceTransactionItem:(NSString *)orderId
                                   sku:(NSString *)sku
                                  name:(NSString *)name
                              category:(NSString *)category
                                 price:(float)price
                              quantity:(int)quantity
                              currency:(NSString *)currency
                               context:(NSDictionary *)context
                             timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];

    [pb addValueToPayload:@"ti" withKey:@"e"];
    [pb addValueToPayload:orderId withKey:@"ti_id"];
    [pb addValueToPayload:sku withKey:@"ti_sk"];
    [pb addValueToPayload:name withKey:@"ti_nm"];
    [pb addValueToPayload:category withKey:@"ti_ca"];
    [pb addValueToPayload:[NSNumber numberWithFloat:price] withKey:@"ti_pr"];
    [pb addValueToPayload:[NSNumber numberWithInt:quantity] withKey:@"ti_qu"];
    [pb addValueToPayload:currency withKey:@"ti_cu"];

    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] withKey:@"dtm"];
    
    [self addTracker:pb];
}

- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSArray *)items
                           context:(NSDictionary *)context
                         timestamp:(double)timestamp {
    SnowplowPayload *pb =  [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];

    [pb addValueToPayload:@"tr" withKey:@"e"];
    [pb addValueToPayload:orderId withKey:@"tr_id"];
    [pb addValueToPayload:[NSNumber numberWithFloat:totalValue] withKey:@"tr_tt"];
    [pb addValueToPayload:affiliation withKey:@"tr_af"];
    [pb addValueToPayload:[NSNumber numberWithFloat:taxValue] withKey:@"tr_tx"];
    [pb addValueToPayload:[NSNumber numberWithFloat:shipping] withKey:@"tr_sh"];
    [pb addValueToPayload:city withKey:@"tr_ci"];
    [pb addValueToPayload:state withKey:@"tr_st"];
    [pb addValueToPayload:country withKey:@"tr_co"];
    [pb addValueToPayload:currency withKey:@"tr_cu"];
    
    NSMutableArray *itemResults;
    
    for (NSMutableDictionary *item in items) {
        [item setObject:[NSNumber numberWithDouble:timestamp] forKey:@"tstamp"];
        [item setObject:orderId forKey:@"order_id"];
        [item setObject:currency forKey:@"currency"];
        [itemResults addObject:item];
    }
    
    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] withKey:@"dtm"];

    // This bit is wrong and needs to be changed, see Fred's comments
    SnowplowPayload *transactionPb = [[SnowplowPayload alloc] init];
    [transactionPb addValueToPayload:pb withKey:@"transaction_result"];
    [transactionPb addValueToPayload:itemResults withKey:@"item_results"];
    
    [self addTracker:pb];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSDictionary *)context
               timestamp:(double)timestamp {
    NSString *snowplowSchema = [NSString stringWithFormat:@"%@/screen_view/%@/1-0-0", kSnowplowVendor, self.schemaTag];
    NSMutableDictionary *screenViewProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 name, @"name", nil];
    if(id_ != 0)
        [screenViewProperties setObject:id_ forKey:@"id"];
    
    NSDictionary *eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               snowplowSchema, @"schema",
                               screenViewProperties, @"data", nil];
    [self trackUnstructuredEvent:eventJson context:context timestamp:timestamp];
}

@end
