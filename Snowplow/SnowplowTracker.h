//
//  SnowplowTracker.h
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

#import <Foundation/Foundation.h>
#import "SnowplowRequest.h"

@interface SnowplowTracker : NSObject

extern NSString * const kSnowplowVendor;
extern Boolean const kDefaultEncodeBase64;
extern NSString * const kVersion;

@property (nonatomic) Boolean base64Encoded;
@property (nonatomic) NSString *trackerNamespace;
@property (nonatomic) SnowplowRequest *collector;
@property (nonatomic) NSMutableDictionary *standardData;

- (id) init;

- (id) initUsingNamespace:(NSString *)namespace
                    appId:(NSString *)appId
            base64Encoded:(Boolean)encoded
                collector:(SnowplowRequest *)collector;

- (void) setCollector:(SnowplowRequest *)collector;

- (void) setNamespace:(NSString *)trackerNamespace;

- (void) setAppId:(NSString *)appId;

- (void) setUserId:(NSString *)userId;

- (void) trackPageView:(NSString *)page_url
                 title:(NSString *)page_title
              referrer:(NSString *)referrer
               context:(NSDictionary *)schema
             timestamp:(double)timestamp;

- (void) trackEcommerceTransactionItem:(NSString *)order_id
                                   sku:(NSString *)sku
                                  name:(NSString *)name
                              category:(NSString *)category
                                 price:(float)price
                              quantity:(int)quantity
                              currency:(NSString *)currency
                               context:(NSDictionary *)schema
                             timestamp:(double)timestamp;

//"""
//:param  order_id:       ID of the eCommerce transaction
//:type   order_id:       non_empty_string
//:param  total_value: Total transaction value
//:type   total_value: int | float
//:param  affiliation: Transaction affiliation
//:type   affiliation: string_or_none
//:param  tax_value:   Transaction tax value
//:type   tax_value:   int | float | None
//:param  shipping:    Delivery cost charged
//:type   shipping:    int | float | None
//:param  city:        Delivery address city
//:type   city:        string_or_none
//:param  state:       Delivery address state
//:type   state:       string_or_none
//:param  country:     Delivery address country
//:type   country:     string_or_none
//:param  currency:    The currency the price is expressed in
//:type   currency:    string_or_none
//:param  items:          The items in the transaction
//:type   items:          list(dict(str:*))
//:param  context:        Custom context for the event
//:type   context:        list(dict(string:*)) | None
//:rtype:                 tracker | dict(string:*)
//"""
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
                           context:(NSDictionary *)context;

@end
