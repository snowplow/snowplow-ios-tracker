//
//  TestGeneratedJsons.m
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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

#import <XCTest/XCTest.h>
#import "IGLUClient.h"
#import "Snowplow.h"
#import "SPEmitter.h"
#import "SPTracker.h"
#import "SPSession.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPEvent.h"
#import "SPSelfDescribingJson.h"

@interface TestGeneratedJsons : XCTestCase

@end

@implementation TestGeneratedJsons {
    IGLUClient * validator;
}

const NSString* IGLU_PATH = @"http://raw.githubusercontent.com/snowplow/iglu-central/master/schemas/";

- (void)setUp {
    [super setUp];
    validator = [[IGLUClient alloc] initWithJsonString:[self getJSONAsStringWithFilePath:@"iglu_resolver.json"] andBundles:[[NSMutableArray alloc] initWithObjects:[NSBundle bundleForClass:[self class]], nil]];
}

- (void)tearDown {
    validator = nil;
    [super tearDown];
}

- (void)testClientSessionContextJson {
    SPSession * session = [[SPSession alloc] init];
    NSDictionary * data = [session getSessionDictWithEventId:@"first-event-id"];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPSessionContextSchema andData:data] getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testPlatformContextJson {
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    NSDictionary * data = [[subject getPlatformDict] getAsDictionary];
    NSDictionary * json;
#if TARGET_OS_IPHONE
    json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPMobileContextSchema andData:data] getAsDictionary];
#else
    json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPDesktopContextSchema andData:data] getAsDictionary];
#endif
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testGeoContextJson {
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:NO andGeoContext:YES];
    [subject setGeoLongitude:5];
    [subject setGeoLatitude:170.2];
    [subject setGeoTimestamp:5];
    [subject setGeoLatitudeLongitudeAccuracy:5.5];
    [subject setGeoSpeed:6.2];
    [subject setGeoBearing:82.3];
    [subject setGeoAltitude:62.3];
    [subject setGeoAltitudeAccuracy:16.3];
    NSDictionary * data = [subject getGeoLocationDict];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPGeoContextSchema andData:data] getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testStructuredEventPayloadJson  {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    SPStructured *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"DemoCategory"];
        [builder setAction:@"DemoAction"];
        [builder setLabel:@"DemoLabel"];
        [builder setProperty:@"DemoProperty"];
        [builder setValue:5];
    }];
    
    // Check that the final payload passes validation
    NSDictionary * data = [[tracker getFinalPayloadWithPayload:[event getPayload] andContext:[event getContexts] andEventId:[event getEventId]] getAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testUnstructuredEventPayloadJson  {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    NSMutableDictionary * input = [[NSMutableDictionary alloc] init];
    [input setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [input setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:input];
    SPUnstructured *event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:sdj];
    }];
    
    // Check that the final payload passes validation
    NSDictionary * data = [[tracker getFinalPayloadWithPayload:[event getPayloadWithEncoding:false] andContext:[event getContexts] andEventId:[event getEventId]] getAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
    
    // Check that the nested unstructured event passes validation
    NSString * ue_pr = [data objectForKey:@"ue_pr"];
    NSDictionary * unstructDictionary = [NSJSONSerialization JSONObjectWithData:[ue_pr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    XCTAssertTrue([validator validateJson:unstructDictionary]);
}

- (void)testPageViewEventPayloadJson {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
    }];
    
    // Check that the final payload passes validation
    NSDictionary * data = [[tracker getFinalPayloadWithPayload:[event getPayload] andContext:[event getContexts] andEventId:[event getEventId]] getAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testEcommerceEventPayloadJson {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    SPEcommerceItem * item = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
        [builder setItemId:transactionID];
        [builder setSku:@"DemoItemSku"];
        [builder setName:@"DemoItemName"];
        [builder setCategory:@"DemoItemCategory"];
        [builder setPrice:0.75F];
        [builder setQuantity:1];
        [builder setCurrency:@"USD"];
    }];
    [itemArray addObject:item];
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
    
    // Check that the main payload passes validation
    NSDictionary * data = [[tracker getFinalPayloadWithPayload:[event getPayload] andContext:[event getContexts] andEventId:[event getEventId]] getAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
    
    // Check that the item payload passes validation
    data = [[tracker getFinalPayloadWithPayload:[item getPayload] andContext:[item getContexts] andEventId:[item getEventId]] getAsDictionary];
    dataArray = [NSArray arrayWithObject:data];
    json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testTimingEventJson {
    SPTiming *event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"DemoTimingCategory"];
        [builder setVariable:@"DemoTimingVariable"];
        [builder setTiming:5];
        [builder setLabel:@"DemoTimingLabel"];
    }];
    NSDictionary * sdj = [[event getPayload] getAsDictionary];
    
    // Test that the SelfDescribingJson passes validation
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testScreenViewEventJson {
    SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"DemoScreenName"];
        [builder setId:@"DemoScreenId"];
    }];
    NSDictionary * sdj = [[event getPayload] getAsDictionary];
    
    // Test that the SelfDescribingJson passes validation
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testFinalEventPayloadJson {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
    }];
    
    // Check that the final payload passes validation
    NSDictionary * data = [[tracker getFinalPayloadWithPayload:[event getPayload] andContext:[event getContexts] andEventId:[event getEventId]] getAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
    
    // Check that the nested context json passes validation
    NSString * contextsJson = [data objectForKey:@"co"];
    NSDictionary * contextDictionary = [NSJSONSerialization JSONObjectWithData:[contextsJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    XCTAssertTrue([validator validateJson:contextDictionary]);
}

- (NSString *)getJSONAsStringWithFilePath:(NSString *)filePath {
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:filePath ofType:nil inDirectory:@"Resources"];
    @try {
        NSData * data = [NSData dataWithContentsOfFile:path];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (SPTracker *)getTracker:(NSString *)url {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:url];
    }];
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    SPTracker * tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:@"anAppId"];
        [builder setTrackerNamespace:@"aNamespace"];
        [builder setBase64Encoded:NO];
        [builder setSessionContext:YES];
    }];
    return tracker;
}

@end
