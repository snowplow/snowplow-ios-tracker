//
//  DemoUtils.m
//  SnowplowDemo
//
//  Copyright (c) 2015-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "DemoUtils.h"
#import "SPPayload.h"
#import "SPTracker.h"
#import "SPSelfDescribingJson.h"
#import "SPEvent.h"

@implementation DemoUtils {}

+ (void) trackAll:(SPTracker *)tracker_ {
    [self trackStructuredEventWithTracker:tracker_];
    [self trackUnstructuredEventWithTracker:tracker_];
    [self trackPageViewWithTracker:tracker_];
    [self trackScreenViewWithTracker:tracker_];
    [self trackTimingWithCategoryWithTracker:tracker_];
    [self trackEcommerceTransactionWithTracker:tracker_];
    [self trackPushNotificationWithTracker:tracker_];
}

// Event Tracking

+ (void) trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    SPStructured *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"DemoCategory"];
        [builder setAction:@"DemoAction"];
        [builder setLabel:@"DemoLabel"];
        [builder setProperty:@"DemoProperty"];
        [builder setValue:5];
    }];
    [tracker_ track:event];
    event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"DemoCategory"];
        [builder setAction:@"DemoAction"];
        [builder setLabel:@"DemoLabel"];
        [builder setProperty:@"DemoProperty"];
        [builder setValue:5];
        [builder setTimestamp:@1243567890];
    }];
    [tracker_ track:event];
}

+ (void) trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSDictionary * data = @{@"targetUrl": @"http://a-target-url.com"};
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1"
                                                                      andData:data];
    SPUnstructured *event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:sdj];
    }];
    [tracker_ track:event];
    event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:sdj];
        [builder setTimestamp:@1243567890];
    }];
    [tracker_ track:event];
}

+ (void) trackPageViewWithTracker:(SPTracker *)tracker_ {
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
    }];
    [tracker_ track:event];
    event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
        [builder setTimestamp:@1243567890];
    }];
    [tracker_ track:event];
}

+ (void) trackScreenViewWithTracker:(SPTracker *)tracker_ {
    NSString *screenId = [[NSUUID UUID] UUIDString];
    SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"DemoScreenName"];
        [builder setScreenId:screenId];
    }];
    [tracker_ track:event];
    event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"DemoScreenName"];
        [builder setScreenId:screenId];
        [builder setTimestamp:@1243567890];
    }];
    [tracker_ track:event];
}

+ (void) trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    SPTiming *event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"DemoTimingCategory"];
        [builder setVariable:@"DemoTimingVariable"];
        [builder setTiming:5];
        [builder setLabel:@"DemoTimingLabel"];
    }];
    [tracker_ track:event];
    event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"DemoTimingCategory"];
        [builder setVariable:@"DemoTimingVariable"];
        [builder setTiming:5];
        [builder setLabel:@"DemoTimingLabel"];
        [builder setTimestamp:@1243567890];
    }];
    [tracker_ track:event];
}

+ (void) trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    [itemArray addObject:[SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
        [builder setItemId:transactionID];
        [builder setSku:@"DemoItemSku"];
        [builder setName:@"DemoItemName"];
        [builder setCategory:@"DemoItemCategory"];
        [builder setPrice:0.75F];
        [builder setQuantity:1];
        [builder setCurrency:@"USD"];
    }]];
    
    SPEcommerce *event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
        [builder setOrderId:transactionID];
        [builder setTotalValue:350];
        [builder setAffiliation:@"DemoTranAffiliation"];
        [builder setTaxValue:10];
        [builder setShipping:15];
        [builder setCity:@"Boston"];
        [builder setState:@"Massachusetts"];
        [builder setCountry:@"USA"];
        [builder setCurrency:@"USD"];
        [builder setItems:itemArray];
    }];
    [tracker_ track:event];
    event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
        [builder setOrderId:transactionID];
        [builder setTotalValue:350];
        [builder setAffiliation:@"DemoTranAffiliation"];
        [builder setTaxValue:10];
        [builder setShipping:15];
        [builder setCity:@"Boston"];
        [builder setState:@"Massachusetts"];
        [builder setCountry:@"USA"];
        [builder setCurrency:@"USD"];
        [builder setItems:itemArray];
        [builder setTimestamp:@1243567890];
    }];
    [tracker_ track:event];
}

+ (void) trackPushNotificationWithTracker:(SPTracker *)tracker_ {
    NSMutableArray * attachments = [[NSMutableArray alloc] init];
    [attachments addObject:@{ @"identifier" : @"testidentifier",
                              @"url" : @"testurl",
                              @"type" : @"testtype"
                              }];

    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:@"test" forKey:@"test"];

    SPNotificationContent * content = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
        [builder setTitle:@"title"];
        [builder setSubtitle:@"subtitle"];
        [builder setBody:@"body"];
        [builder setBadge:[NSNumber numberWithInt:5]];
        [builder setSound:@"sound"];
        [builder setLaunchImageName:@"launchImageName"];
        [builder setUserInfo: [NSDictionary dictionaryWithDictionary:userInfo]];
        [builder setAttachments: [NSArray arrayWithArray:attachments]];
    }];

    SPPushNotification * event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
        [builder setAction:@"action"];
        [builder setTrigger:@"PUSH"];
        [builder setDeliveryDate:@"date"];
        [builder setCategoryIdentifier:@"category"];
        [builder setThreadIdentifier:@"thread"];
        [builder setNotification:content];
    }];

    [tracker_ track:event];
}

@end
