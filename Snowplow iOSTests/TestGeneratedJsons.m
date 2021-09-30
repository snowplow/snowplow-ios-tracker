//
//  TestGeneratedJsons.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import <SnowplowIgluClient/IGLUClient.h>
#import "SPTrackerConstants.h"
#import "SPEmitter.h"
#import "SPTracker.h"
#import "SPSession.h"
#import "SPSubject.h"
#import "SPGdprContext.h"
#import "SPPayload.h"
#import "SPEvent.h"
#import "SPSelfDescribingJson.h"
#import "SPUtilities.h"
#import "SPTrackerEvent.h"
#import "SPServiceProvider.h"
#import "SPScreenState.h"

/// Category needed to make the private methods testable.
@interface SPTracker (Testing)
- (SPPayload *)payloadWithEvent:(SPTrackerEvent *)event;
@end


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

- (void) testScreenContextJson {
    SPScreenState * screen = [[SPScreenState alloc] initWithName:@"name" type:@"type" screenId:nil transitionType:@"transition" topViewControllerClassName:@"topVCname" viewControllerClassName:@"VCname"];
    SPSelfDescribingJson * json = [SPUtilities getScreenContextWithScreenState:screen];
    XCTAssertTrue([validator validateJson:[json getAsDictionary]]);
}

- (void)testClientSessionContextJson {
    SPSession * session = [[SPSession alloc] init];
    NSDictionary * data = [session getSessionDictWithEventId:@"first-event-id"];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPSessionContextSchema andData:data] getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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
    [subject setGeoLatitude:89.2];
    [subject setGeoTimestamp:@5];
    [subject setGeoLatitudeLongitudeAccuracy:5.5];
    [subject setGeoSpeed:6.2];
    [subject setGeoBearing:82.3];
    [subject setGeoAltitude:62.3];
    [subject setGeoAltitudeAccuracy:16.3];
    NSDictionary * data = [subject getGeoLocationDict];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPGeoContextSchema andData:data] getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
}

#pragma clang diagnostic pop

- (void)testGdprContextJson {
    SPGdprContext *gdpr = [[SPGdprContext alloc] initWithBasis:SPGdprProcessingBasisConsent
                                                    documentId:@"id"
                                               documentVersion:@"version"
                                           documentDescription:@"description"];
    XCTAssertTrue([validator validateJson:[gdpr.context getAsDictionary]]);
}

- (void)testStructuredEventPayloadJson  {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    [tracker setBase64Encoded:false];
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"DemoCategory" action:@"DemoAction"];
    event.label = @"DemoLabel";
    event.property = @"DemoProperty";
    event.value = @5;
    
    // Check that the final payload passes validation
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    NSDictionary *data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    NSArray * dataArray = [NSArray arrayWithObject:data];
    NSDictionary * json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testUnstructuredEventPayloadJson  {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    [tracker setBase64Encoded:false];
    NSMutableDictionary * input = [[NSMutableDictionary alloc] init];
    [input setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [input setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson *sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:input];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:sdj];
    
    // Check that the final payload passes validation
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    NSDictionary<NSString *, NSObject *> *data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    NSArray *dataArray = [NSArray arrayWithObject:data];
    NSDictionary<NSString *, NSObject *> *json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];

    XCTAssertTrue([validator validateJson:json]);
    
    // Check that the nested unstructured event passes validation
    NSString * ue_pr = (NSString *)[data objectForKey:@"ue_pr"];
    NSDictionary *unstructDictionary = [NSJSONSerialization JSONObjectWithData:[ue_pr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    XCTAssertTrue([validator validateJson:unstructDictionary]);
}

- (void)testSelfDescribingEventPayloadJson  {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    [tracker setBase64Encoded:false];
    NSMutableDictionary * input = [[NSMutableDictionary alloc] init];
    [input setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [input setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:input];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:sdj];

    // Check that the final payload passes validation
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    NSDictionary<NSString *, NSObject *> *data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    NSArray *dataArray = [NSArray arrayWithObject:data];
    NSDictionary<NSString *, NSObject *> *json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];

    XCTAssertTrue([validator validateJson:json]);

    // Check that the nested unstructured event passes validation
    NSString *ue_pr = (NSString *)[data objectForKey:@"ue_pr"];
    NSDictionary *unstructDictionary = [NSJSONSerialization JSONObjectWithData:[ue_pr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

    XCTAssertTrue([validator validateJson:unstructDictionary]);
}

- (void)testConsentWithdrawnEventPayloadJson {
    SPConsentWithdrawn *event = [[SPConsentWithdrawn alloc] init];
    [event documentDescription:@"Description"];
    [event documentId:@"1234"];
    [event version:@"10"];
    [event all:false];
    [event name:@"Name"];

    NSDictionary<NSString *, NSObject *> *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testConsentDocumentEventPayloadJson {
    SPConsentDocument *event = [[SPConsentDocument alloc] initWithDocumentId:@"1234" version:@"10"];
    [event documentDescription:@"Description"];
    [event name:@"Name"];
    
    NSDictionary<NSString *, NSObject *> *sdj = [[event getPayload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testConsentGrantedEventPayloadJson {
    SPConsentGranted *event = [[SPConsentGranted alloc] initWithExpiry:@"2012-04-23T18:25:43.511Z" documentId:@"1234" version:@"10"];
    [event documentDescription:@"Description"];
    [event name:@"Name"];
    
    NSDictionary<NSString *, NSObject *> *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testPageViewEventPayloadJson {
    SPTracker *tracker = [self getTracker:@"acme.fake.url"];
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    event.pageTitle = @"DemoPageTitle";
    event.referrer = @"DemoPageReferrer";

    // Check that the final payload passes validation
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    NSDictionary<NSString *, NSObject *> *data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    NSArray *dataArray = [NSArray arrayWithObject:data];
    NSDictionary<NSString *, NSObject *> *json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testEcommerceEventPayloadJson {
    SPTracker * tracker = [self getTracker:@"acme.fake.url"];
    
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    SPEcommerceItem *item = [[SPEcommerceItem alloc] initWithSku:@"DemoItemSku" price:@0.75F quantity:@1];
    [item name:@"DemoItemName"];
    [item category:@"DemoItemCategory"];
    [item currency:@"USD"];
    
    [itemArray addObject:item];
    SPEcommerce *event = [[SPEcommerce alloc] initWithOrderId:transactionID totalValue:@350 items:itemArray];
    [event affiliation:@"DemoTranAffiliation"];
    [event taxValue:@10];
    [event shipping:@15];
    [event city:@"Boston"];
    [event state:@"Massachusetts"];
    [event country:@"USA"];
    [event currency:@"USD"];

    // Check that the main payload passes validation
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    NSDictionary<NSString *, NSObject *> *data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    NSArray *dataArray = [NSArray arrayWithObject:data];
    NSDictionary<NSString *, NSObject *> *json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
    
    // Check that the item payload passes validation
    data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    dataArray = [NSArray arrayWithObject:data];
    json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testTimingEventJson {
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:@5];
    NSDictionary<NSString *, NSObject *> *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testScreenViewEventJson {
    SPScreenView *event = [[SPScreenView alloc] initWithName:@"DemoScreenName" screenId:[NSUUID UUID]];
    NSDictionary<NSString *, NSObject *> *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testPushNotificationEventJson {
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    [attachments addObject:@{ kSPPnAttachmentId : @"identifier",
                              kSPPnAttachmentUrl : @"url",
                              kSPPnAttachmentType : @"type"
                              }];

    NSDictionary *userInfo = @{@"aps":
                                    @{@"alert":
                                          @{@"title": @"test title",
                                            @"body": @"test",
                                            @"loc-key": @"test key"
                                            },
                                      @"content-available": @0
                                          }
                                    };

    SPNotificationContent *content = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"body" badge:@5];
    [content subtitle:@"subtitle"];
    [content sound:@"sound"];
    [content launchImageName:@"launchImageName"];
    [content userInfo: userInfo];

    SPPushNotification *event = [[SPPushNotification alloc] initWithDate:@"date" action:@"action" trigger:@"PUSH" category:@"category" thread:@"thread" notification:content];
    
    NSDictionary *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testMessageNotificationEventJson {
    NSDictionary *userInfo = @{@"aps":
                                    @{@"alert":
                                          @{@"title": @"test title",
                                            @"body": @"test",
                                            @"loc-key": @"test key"
                                            },
                                      @"content-available": @0
                                          }
                                    };
    SPMessageNotification *event = [SPMessageNotification messageNotificationWithUserInfo:userInfo defaultTitle:nil defaultBody:nil];
    NSDictionary *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testApplicationInstallJson {
    SPSelfDescribingJson *installEvent = [[SPSelfDescribingJson alloc] initWithSchema:kSPApplicationInstallSchema andData:@{}];
    NSDictionary<NSString *, NSObject *> *json = [installEvent getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
}

- (void)testApplicationContextJson {
    SPSelfDescribingJson *json = [SPUtilities getApplicationContextWithVersion:@"testversion" andBuild:@"testbuild"];
    XCTAssertTrue([validator validateJson:[json getAsDictionary]]);
}

- (void)testErrorEventJson {
    SNOWError *event = [[SNOWError alloc] initWithMessage:@"some error message"];
    event.name = @"some exception name";
    event.stackTrace = @"some stack trace";
    NSDictionary<NSString *, NSObject *> *sdj = [[[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload] getAsDictionary];
    XCTAssertTrue([validator validateJson:sdj]);
}

- (void)testFinalEventPayloadJson {
    SPTracker *tracker = [self getTracker:@"acme.fake.url"];
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    [event pageTitle:@"DemoPageTitle"];
    [event referrer:@"DemoPageReferrer"];
    
    // Check that the final payload passes validation
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    NSDictionary<NSString *, NSObject *> *data = [[tracker payloadWithEvent:trackerEvent] getAsDictionary];

    NSArray *dataArray = [NSArray arrayWithObject:data];
    NSDictionary<NSString *, NSObject *> *json = [[[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:dataArray] getAsDictionary];
    XCTAssertTrue([validator validateJson:json]);
    
    // Check that the nested context json passes validation
    NSString *contextsJson = (NSString *)[data objectForKey:@"co"];
    NSDictionary *contextDictionary = [NSJSONSerialization JSONObjectWithData:[contextsJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    XCTAssertTrue([validator validateJson:contextDictionary]);
}

- (NSString *)getJSONAsStringWithFilePath:(NSString *)filePath {
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:filePath ofType:nil inDirectory:@"Products"];
    @try {
        NSData * data = [NSData dataWithContentsOfFile:path];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (SPTracker *)getTracker:(NSString *)url {
    NSString *endpoint = [NSString stringWithFormat:@"https://%@", url];
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"anAppId"];
    trackerConfig.platformContext = YES;
    trackerConfig.geoLocationContext = YES;
    trackerConfig.base64Encoding = NO;
    trackerConfig.sessionContext = YES;
    SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNamespace:@"aNamespace" network:networkConfig configurations:@[trackerConfig]];
    return serviceProvider.tracker;
}

@end
