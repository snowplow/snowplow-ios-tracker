//
//  DemoUtils.m
//  SnowplowDemo
//
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "DemoUtils.h"
#import "SPPayload.h"
#import "SPTracker.h"

@implementation DemoUtils {}

+ (void) trackAll:(SPTracker *)tracker_ {
    [self trackStructuredEventWithTracker:tracker_];
    [self trackUnstructuredEventWithTracker:tracker_];
    [self trackPageViewWithTracker:tracker_];
    [self trackScreenViewWithTracker:tracker_];
    [self trackTimingWithCategoryWithTracker:tracker_];
    [self trackEcommerceTransactionWithTracker:tracker_];
}

// Event Tracking

+ (void) trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5];
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5 context:[self getCustomContext]];
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5 timestamp:1243567890];
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5 context:[self getCustomContext] timestamp:1243567890];
}

+ (void) trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSDictionary *event = @{
                            @"schema":@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
                            @"data": @{
                                    @"level": @23,
                                    @"score": @56473
                                    }
                            };
    [tracker_ trackUnstructuredEvent:event];
    [tracker_ trackUnstructuredEvent:event context:[self getCustomContext]];
    [tracker_ trackUnstructuredEvent:event timestamp:1243567890];
    [tracker_ trackUnstructuredEvent:event context:[self getCustomContext] timestamp:1243567890];
}

+ (void) trackPageViewWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer"];
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer" context:[self getCustomContext]];
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer" timestamp:1243567890];
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer" context:[self getCustomContext] timestamp:1243567890];
}

+ (void) trackScreenViewWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId"];
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId" context:[self getCustomContext]];
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId" timestamp:1243567890];
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId" context:[self getCustomContext] timestamp:1243567890];
}

+ (void) trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel"];
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel" context:[self getCustomContext]];
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel" timestamp:1243567890];
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel" context:[self getCustomContext] timestamp:1243567890];
}

+ (void) trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    [itemArray addObject:[tracker_ trackEcommerceTransactionItem:transactionID
                                                             sku:@"DemoItemSku"
                                                            name:@"DemoItemName"
                                                        category:@"DemoItemCategory"
                                                           price:0.75F
                                                        quantity:1
                                                        currency:@"USD"]];
    
    [tracker_ trackEcommerceTransaction:transactionID
                             totalValue:350
                            affiliation:@"DemoTranAffiliation"
                               taxValue:10
                               shipping:15
                                   city:@"Boston"
                                  state:@"Massachusetts"
                                country:@"USA"
                               currency:@"USD"
                                  items:itemArray];

     [tracker_ trackEcommerceTransaction:transactionID
     totalValue:350
     affiliation:@"DemoTranAffiliation"
     taxValue:10
     shipping:15
     city:@"Boston"
     state:@"Massachusetts"
     country:@"USA"
     currency:@"USD"
     items:itemArray
     context:[self getCustomContext]];
     
     [tracker_ trackEcommerceTransaction:transactionID
     totalValue:350
     affiliation:@"DemoTranAffiliation"
     taxValue:10
     shipping:15
     city:@"Boston"
     state:@"Massachusetts"
     country:@"USA"
     currency:@"USD"
     items:itemArray
     timestamp:1243567890];
     
     [tracker_ trackEcommerceTransaction:transactionID
     totalValue:350
     affiliation:@"DemoTranAffiliation"
     taxValue:10
     shipping:15
     city:@"Boston"
     state:@"Massachusetts"
     country:@"USA"
     currency:@"USD"
     items:itemArray
     context:[self getCustomContext]
     timestamp:1243567890];
}

// Helpers

+ (NSMutableArray *) getCustomContext {
    NSDictionary *context = @{
                              @"schema":@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0",
                              @"data": @{
                                      @"snowplow": @"demo-tracker"
                                      }
                              };
    return [NSMutableArray arrayWithArray:@[context]];
}

@end
