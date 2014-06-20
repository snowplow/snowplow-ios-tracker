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
NSString * const kVersion               = @"ios-0.1";

@synthesize collector;
@synthesize appId;
@synthesize trackerNamespace;
@synthesize userId;

- (id) init {
    self = [super init];
    if(self) {
        [self setSchemaTag:@"jsonschema"];
        trackerNamespace = nil;
        _base64Encoded = true;
        collector = nil;
        _standardData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             kVersion, @"tv", nil];
    }
    return self;
}

- (id) initUsingCollector:(SnowplowRequest *)collector_
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
            context:(NSDictionary *)context {
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithObjects:context, nil];
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                               _contextSchema, @"$schema",
                               dataArray, @"data", nil];
    [self setMobileContext:dataArray];
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
    [mobContext addValueToPayload:[SnowplowUtils getDeviceVendor] forKey:@"deviceVendor"];
    [mobContext addValueToPayload:[SnowplowUtils getDeviceModel] forKey:@"deviceModel"];
    [mobContext addValueToPayload:[SnowplowUtils getCarrierName] forKey:@"carrier"];
    [mobContext addValueToPayload:[SnowplowUtils getOpenIdfa] forKey:@"openIdfa"];
    [mobContext addValueToPayload:[SnowplowUtils getAppleIdfa] forKey:@"appleIdfa"];
    
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              schema, @"$schema",
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
    [payload addValueToPayload:[NSNumber numberWithDouble:[SnowplowUtils getTimestamp]] forKey:@"dtm"];
}

- (void) addTracker:(SnowplowPayload *)event {
    [collector addPayloadToBuffer:event];
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
    
    [pb addValueToPayload:@"se" forKey:@"e"];
    [pb addValueToPayload:category forKey:@"se_ca"];
    [pb addValueToPayload:action forKey:@"se_ac"];
    [pb addValueToPayload:label forKey:@"se_la"];
    [pb addValueToPayload:property forKey:@"se_pr"];
    [pb addValueToPayload:[NSNumber numberWithFloat:value] forKey:@"se_va"];
    
    if (timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] forKey:@"dtm"];

    [self addTracker:pb];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSDictionary *)context
                      timestamp:(double)timestamp {
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    
    [pb addValueToPayload:@"ue" forKey:@"e"];

    // Creates similar envelop as in setContext with but different encoding keys
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                          _contextSchema, @"$schema",
                          context, @"data", nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:_base64Encoded
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
    [pb addValueToPayload:@"pv"      forKey:@"e"];
    [pb addValueToPayload:pageUrl   forKey:@"url"];
    [pb addValueToPayload:pageTitle forKey:@"page"];
    [pb addValueToPayload:referrer   forKey:@"refr"];

    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] forKey:@"dtm"];
    
    [self addTracker:pb];
}

- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
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

    [pb addValueToPayload:@"ti" forKey:@"e"];
    [pb addValueToPayload:orderId forKey:@"ti_id"];
    [pb addValueToPayload:sku forKey:@"ti_sk"];
    [pb addValueToPayload:name forKey:@"ti_nm"];
    [pb addValueToPayload:category forKey:@"ti_ca"];
    [pb addValueToPayload:[NSNumber numberWithFloat:price] forKey:@"ti_pr"];
    [pb addValueToPayload:[NSNumber numberWithInt:quantity] forKey:@"ti_qu"];
    [pb addValueToPayload:currency forKey:@"ti_cu"];

    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] forKey:@"dtm"];
    
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
                             items:(NSArray *)items
                           context:(NSDictionary *)context
                         timestamp:(double)timestamp {
    SnowplowPayload *pb =  [[SnowplowPayload alloc] init];
    [self addStandardValuesToPayload:pb];
    [self setContext:pb context:context];

    [pb addValueToPayload:@"tr" forKey:@"e"];
    [pb addValueToPayload:orderId forKey:@"tr_id"];
    [pb addValueToPayload:[NSNumber numberWithFloat:totalValue] forKey:@"tr_tt"];
    [pb addValueToPayload:affiliation forKey:@"tr_af"];
    [pb addValueToPayload:[NSNumber numberWithFloat:taxValue] forKey:@"tr_tx"];
    [pb addValueToPayload:[NSNumber numberWithFloat:shipping] forKey:@"tr_sh"];
    [pb addValueToPayload:city forKey:@"tr_ci"];
    [pb addValueToPayload:state forKey:@"tr_st"];
    [pb addValueToPayload:country forKey:@"tr_co"];
    [pb addValueToPayload:currency forKey:@"tr_cu"];
    
    NSMutableArray *itemResults;
    
    for (NSMutableDictionary *item in items) {
        [item setObject:[NSNumber numberWithDouble:timestamp] forKey:@"tstamp"];
        [item setObject:orderId forKey:@"order_id"];
        [item setObject:currency forKey:@"currency"];
        [itemResults addObject:item];
    }
    
    if(timestamp != 0)
        [pb addValueToPayload:[NSNumber numberWithDouble:timestamp] forKey:@"dtm"];
    
    [self addTracker:pb];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSDictionary *)context
               timestamp:(double)timestamp {
    NSString *snowplowSchema = [NSString stringWithFormat:@"%@/screen_view/%@/1-0-0", kSnowplowVendor, _schemaTag];
    NSMutableDictionary *screenViewProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 name, @"name", nil];
    if(id_ != 0)
        [screenViewProperties setObject:id_ forKey:@"id"];
    
    NSDictionary *eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               snowplowSchema, @"$schema",
                               screenViewProperties, @"data", nil];
    [self trackUnstructuredEvent:eventJson context:context timestamp:timestamp];
}

@end
