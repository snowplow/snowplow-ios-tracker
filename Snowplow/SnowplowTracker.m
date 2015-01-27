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

@implementation SnowplowTracker {
    Boolean                 _base64Encoded;
    NSMutableDictionary *   _standardData;
    NSString *              _schemaTag;
    NSString *              _contextSchema;
    NSString *              _unstructedEventSchema;
}

NSString * const kSnowplowVendor        = @"com.snowplowanalytics.snowplow";
NSString * const kIglu                  = @"iglu:";
Boolean    const kDefaultEncodeBase64   = true;
NSString * const kVersion               = @"ios-0.2.2";

@synthesize collector;
@synthesize appId;
@synthesize trackerNamespace;
@synthesize userId;

- (id) init {
    return [self initWithCollector:nil appId:nil base64Encoded:true namespace:nil];
}

- (id) initWithCollector:(SnowplowRequest *)collector_
                   appId:(NSString *)appId_
           base64Encoded:(Boolean)encoded
               namespace:(NSString *)namespace_ {
    self = [super init];
    if(self) {
        [self setSchemaTag:@"jsonschema"];
        trackerNamespace = namespace_;
        _base64Encoded = encoded;
        collector = collector_;
        _standardData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         kVersion, @"tv",
                         namespace_, @"tna",
                         appId_, @"aid", nil];
    }
    return self;
}

- (void) setUserId:(NSString *)userId_ {
    userId = userId_;
    [_standardData setObject:userId_ forKey:@"uid"];
}

- (void) setSchemaTag:(NSString *)schema {
    _schemaTag = schema;
    _contextSchema = [NSString stringWithFormat:@"%@%@/contexts/%@/1-0-0",
                      kIglu, kSnowplowVendor, schema];
    _unstructedEventSchema = [NSString stringWithFormat:@"%@%@/unstruct_event/%@/1-0-0",
                              kIglu, kSnowplowVendor, schema];
}

- (void) setContext:(SnowplowPayload *)pb
            context:(NSMutableArray *)contextArray {
    if (contextArray == nil) {
        contextArray = [[NSMutableArray alloc] init];
    }
    
    [self setMobileContext:contextArray];
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              _contextSchema, @"schema",
                              contextArray, @"data", nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:_base64Encoded
               typeWhenEncoded:@"cx"
            typeWhenNotEncoded:@"co"];
}

- (void) setMobileContext: (NSMutableArray *)payloadData {
    SnowplowPayload *mobContext = [[SnowplowPayload alloc] init];
    
    NSString *schema = [NSString stringWithFormat:@"%@%@/mobile_context/jsonschema/1-0-0",
                        kIglu, kSnowplowVendor];
    
    [mobContext addValueToPayload:[SnowplowUtils getOSType] forKey:@"osType"];
    [mobContext addValueToPayload:[SnowplowUtils getOSVersion] forKey:@"osVersion"];
    [mobContext addValueToPayload:[SnowplowUtils getDeviceVendor] forKey:@"deviceManufacturer"];
    [mobContext addValueToPayload:[SnowplowUtils getDeviceModel] forKey:@"deviceModel"];
    [mobContext addValueToPayload:[SnowplowUtils getCarrierName] forKey:@"carrier"];
    [mobContext addValueToPayload:[SnowplowUtils getOpenIdfa] forKey:@"openIdfa"];
    [mobContext addValueToPayload:[SnowplowUtils getAppleIdfa] forKey:@"appleIdfa"];
    [mobContext addValueToPayload:[SnowplowUtils getAppleIdfv] forKey:@"appleIdfv"];
    
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              schema, @"schema",
                              mobContext.getPayloadAsDictionary, @"data", nil];
    [payloadData addObject:envelope];
}

- (void) addStandardValuesToPayload:(SnowplowPayload *)payload {
    [payload addDictionaryToPayload:_standardData];
    [payload addValueToPayload:[SnowplowUtils getPlatform] forKey:@"p"];
    [payload addValueToPayload:[SnowplowUtils getResolution] forKey:@"res"];
    [payload addValueToPayload:[SnowplowUtils getViewPort] forKey:@"vp"];
    [payload addValueToPayload:[SnowplowUtils getEventId] forKey:@"eid"];
    [payload addValueToPayload:[SnowplowUtils getLanguage] forKey:@"lang"];
    [payload addValueToPayload:[NSString stringWithFormat:@"%.0f", [SnowplowUtils getTimestamp]] forKey:@"dtm"];
}

- (double) setTimestamp:(double)timestamp toPayload:(SnowplowPayload *)payload {
    double tstamp = timestamp;
    if(timestamp == 0) {
        tstamp = [SnowplowUtils getTimestamp];
    }
    [payload addValueToPayload:[NSString stringWithFormat:@"%.0f", tstamp] forKey:@"dtm"];
    
    return tstamp;
}

- (void) addTracker:(SnowplowPayload *)event {
    [collector addPayloadToBuffer:event];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer {
    [self trackPageView:pageUrl title:pageTitle referrer:referrer context:nil timestamp:0];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSMutableArray *)context {
    [self trackPageView:pageUrl title:pageTitle referrer:referrer context:context timestamp:0];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
             timestamp:(double)timestamp {
    [self trackPageView:pageUrl title:pageTitle referrer:referrer context:nil timestamp:timestamp];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSMutableArray *)context
             timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];
    [pb addValueToPayload:@"pv"      forKey:@"e"];
    [pb addValueToPayload:pageUrl   forKey:@"url"];
    [pb addValueToPayload:pageTitle forKey:@"page"];
    [pb addValueToPayload:referrer   forKey:@"refr"];
    
    [self addTracker:pb];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value {
    [self trackStructuredEvent:category action:action label:label property:property value:value context:nil timestamp:0];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSMutableArray *)context {
    [self trackStructuredEvent:category action:action label:label property:property value:value context:context timestamp:0];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                    timestamp:(double)timestamp {
    [self trackStructuredEvent:category action:action label:label property:property value:value context:nil timestamp:timestamp];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSMutableArray *)context
                    timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];
    
    [pb addValueToPayload:@"se" forKey:@"e"];
    [pb addValueToPayload:category forKey:@"se_ca"];
    [pb addValueToPayload:action forKey:@"se_ac"];
    [pb addValueToPayload:label forKey:@"se_la"];
    [pb addValueToPayload:property forKey:@"se_pr"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", value] forKey:@"se_va"];
    
    [self addTracker:pb];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson {
    [self trackUnstructuredEvent:eventJson context:nil timestamp:0];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSMutableArray *)context {
    [self trackUnstructuredEvent:eventJson context:context timestamp:0];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                      timestamp:(double)timestamp {
    [self trackUnstructuredEvent:eventJson context:nil timestamp:timestamp];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSMutableArray *)context
                      timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];
    [pb addValueToPayload:@"ue" forKey:@"e"];
    
    // Creates similar envelop as in setContext with but different encoding keys
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              _unstructedEventSchema, @"schema",
                              eventJson, @"data", nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:_base64Encoded
               typeWhenEncoded:@"ue_px"
            typeWhenNotEncoded:@"ue_pr"];
    
    [self addTracker:pb];
}

- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency {
    return [self trackEcommerceTransactionItem:orderId sku:sku name:name category:category price:price quantity:quantity currency:currency context:nil timestamp:0];
}

- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency
                                            context:(NSMutableArray *)context {
    return [self trackEcommerceTransactionItem:orderId sku:sku name:name category:category price:price quantity:quantity currency:currency context:context timestamp:0];
}

- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency
                                          timestamp:(double)timestamp {
    return [self trackEcommerceTransactionItem:orderId sku:sku name:name category:category price:price quantity:quantity currency:currency context:nil timestamp:timestamp];
}

- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency
                                            context:(NSMutableArray *)context
                                          timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];
    
    [pb addValueToPayload:@"ti" forKey:@"e"];
    [pb addValueToPayload:orderId forKey:@"ti_id"];
    [pb addValueToPayload:sku forKey:@"ti_sk"];
    [pb addValueToPayload:name forKey:@"ti_na"];
    [pb addValueToPayload:category forKey:@"ti_ca"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", price] forKey:@"ti_pr"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%d", quantity] forKey:@"ti_qu"];
    [pb addValueToPayload:currency forKey:@"ti_cu"];
    
    return pb;
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
                             items:(NSArray *)items {
    [self trackEcommerceTransaction:orderId totalValue:totalValue affiliation:affiliation taxValue:taxValue shipping:shipping city:city state:state country:country currency:currency items:items context:nil timestamp:0];
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
                           context:(NSMutableArray *)context {
    [self trackEcommerceTransaction:orderId totalValue:totalValue affiliation:affiliation taxValue:taxValue shipping:shipping city:city state:state country:country currency:currency items:items context:context timestamp:0];
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
                         timestamp:(double)timestamp {
    [self trackEcommerceTransaction:orderId totalValue:totalValue affiliation:affiliation taxValue:taxValue shipping:shipping city:city state:state country:country currency:currency items:items context:nil timestamp:timestamp];
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
                           context:(NSMutableArray *)context
                         timestamp:(double)timestamp {
    SnowplowPayload *pb =  [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];
    
    [pb addValueToPayload:@"tr" forKey:@"e"];
    [pb addValueToPayload:orderId forKey:@"tr_id"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", totalValue] forKey:@"tr_tt"];
    [pb addValueToPayload:affiliation forKey:@"tr_af"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", taxValue] forKey:@"tr_tx"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", shipping] forKey:@"tr_sh"];
    [pb addValueToPayload:city forKey:@"tr_ci"];
    [pb addValueToPayload:state forKey:@"tr_st"];
    [pb addValueToPayload:country forKey:@"tr_co"];
    [pb addValueToPayload:currency forKey:@"tr_cu"];
    
    double tstamp = [self setTimestamp:timestamp toPayload:pb];
    
    for (SnowplowPayload *item in items) {
        [item addValueToPayload:[NSString stringWithFormat:@"%.0f", tstamp] forKey:@"tstamp"];
        [item addValueToPayload:orderId forKey:@"order_id"];
        [item addValueToPayload:currency forKey:@"currency"];
        [self addTracker:item];
    }
    
    [self addTracker:pb];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_ {
    [self trackScreenView:name id:id_ context:nil timestamp:0];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSMutableArray *)context {
    [self trackScreenView:name id:id_ context:context timestamp:0];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
               timestamp:(double)timestamp {
    [self trackScreenView:name id:id_ context:nil timestamp:timestamp];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSMutableArray *)context
               timestamp:(double)timestamp {
    NSString *snowplowSchema = [NSString stringWithFormat:@"%@%@/screen_view/%@/1-0-0", kIglu, kSnowplowVendor, _schemaTag];
    NSMutableDictionary *screenViewProperties = [[NSMutableDictionary alloc] init];
    if(id_ != nil)
        [screenViewProperties setObject:id_ forKey:@"id"];
    if (name != nil) {
        [screenViewProperties setObject:name forKey:@"name"];
    }
    
    NSDictionary *eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               snowplowSchema, @"schema",
                               screenViewProperties, @"data", nil];
    [self trackUnstructuredEvent:eventJson context:context timestamp:timestamp];
}

@end
