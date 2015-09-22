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
#import "KiteJSONValidator.h"
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
    KiteJSONValidator * validator;
}

const NSString* IGLU_PATH = @"http://raw.githubusercontent.com/snowplow/iglu-central/master/schemas/";

- (void)setUp {
    [super setUp];
    validator = [KiteJSONValidator new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testClientSessionContextJson {
    SPSession * session = [[SPSession alloc] init];
    NSDictionary * data = [session getSessionDictWithEventId:@"first-event-id"];
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPSessionContextSchema];
    XCTAssertTrue([validator validateJSONInstance:data withSchema:schema]);
}

- (void)testPlatformContextJson {
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES];
    NSDictionary * data = [[subject getPlatformDict] getPayloadAsDictionary];
    NSDictionary * schema;
#if TARGET_OS_IPHONE
    schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPMobileContextSchema];
#else
    schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPDesktopContextSchema];
#endif
    XCTAssertTrue([validator validateJSONInstance:data withSchema:schema]);
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
    NSDictionary * data = [[tracker getFinalPayload:[event getPayload] context:[event getContexts] eventId:[event getEventId]] getPayloadAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPPayloadDataSchema];
    XCTAssertTrue([validator validateJSONInstance:dataArray withSchema:schema]);
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
    NSDictionary * data = [[tracker getFinalPayload:[event getPayloadWithEncoding:false] context:[event getContexts] eventId:[event getEventId]] getPayloadAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPPayloadDataSchema];
    XCTAssertTrue([validator validateJSONInstance:dataArray withSchema:schema]);
    
    // Check that the nested unstructured event passes validation
    NSString * ue_pr = [data objectForKey:@"ue_pr"];
    NSDictionary * unstructDictionary = [NSJSONSerialization JSONObjectWithData:[ue_pr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPUnstructSchema];
    XCTAssertTrue([validator validateJSONInstance:unstructDictionary withSchema:schema]);
}

- (void)testPageViewEventPayloadJson {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
    }];
    
    // Check that the final payload passes validation
    NSDictionary * data = [[tracker getFinalPayload:[event getPayload] context:[event getContexts] eventId:[event getEventId]] getPayloadAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPPayloadDataSchema];
    XCTAssertTrue([validator validateJSONInstance:dataArray withSchema:schema]);
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
    NSDictionary * data = [[tracker getFinalPayload:[event getPayload] context:[event getContexts] eventId:[event getEventId]] getPayloadAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPPayloadDataSchema];
    XCTAssertTrue([validator validateJSONInstance:dataArray withSchema:schema]);
    
    // Check that the item payload passes validation
    data = [[tracker getFinalPayload:[item getPayload] context:[item getContexts] eventId:[item getEventId]] getPayloadAsDictionary];
    dataArray = [NSArray arrayWithObject:data];
    XCTAssertTrue([validator validateJSONInstance:dataArray withSchema:schema]);
}

- (void)testTimingEventJson {
    SPTiming *event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"DemoTimingCategory"];
        [builder setVariable:@"DemoTimingVariable"];
        [builder setTiming:5];
        [builder setLabel:@"DemoTimingLabel"];
    }];
    NSDictionary * sdj = [[event getPayload] getAsDictionary];
    
    // Test that the SelfDescribingJson passes unstruct_event validation
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPUnstructSchema];
    XCTAssertTrue([validator validateJSONInstance:sdj withSchema:schema]);
    
    // Test that the data passes timing validation
    NSDictionary * data = [sdj objectForKey:@"data"];
    schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPUserTimingsSchema];
    XCTAssertTrue([validator validateJSONInstance:data withSchema:schema]);
}

- (void)testScreenViewEventJson {
    SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"DemoScreenName"];
        [builder setId:@"DemoScreenId"];
    }];
    NSDictionary * sdj = [[event getPayload] getAsDictionary];
    
    // Test that the SelfDescribingJson passes unstruct_event validation
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPUnstructSchema];
    XCTAssertTrue([validator validateJSONInstance:sdj withSchema:schema]);
    
    // Test that the data passes timing validation
    NSDictionary * data = [sdj objectForKey:@"data"];
    schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPScreenViewSchema];
    XCTAssertTrue([validator validateJSONInstance:data withSchema:schema]);
}

- (void)testFinalEventPayloadJson {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
    }];
    
    // Check that the final payload passes validation
    NSDictionary * data = [[tracker getFinalPayload:[event getPayload] context:[event getContexts] eventId:[event getEventId]] getPayloadAsDictionary];
    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPPayloadDataSchema];
    XCTAssertTrue([validator validateJSONInstance:dataArray withSchema:schema]);
    
    // Check that the nested context json passes validation
    NSString * contextsJson = [data objectForKey:@"co"];
    NSDictionary * contextDictionary = [NSJSONSerialization JSONObjectWithData:[contextsJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSArray * contextArray = [contextDictionary objectForKey:@"data"];
    schema = [self getJSONSchemaAsDictionaryWithIgluPath:kSPContextSchema];
    XCTAssertTrue([validator validateJSONInstance:contextArray withSchema:schema]);
}

- (NSDictionary *)getJSONSchemaAsDictionaryWithIgluPath:(NSString *)raw {
    NSBundle * mainBundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [mainBundle pathForResource:[raw substringFromIndex:5] ofType:nil inDirectory:@"Resources"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (SPTracker *)getTracker:(NSString *)url {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:url];
    }];
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES];
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
