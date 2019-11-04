//
//  ViewController.m
//  SnowplowDemo
//
//  Copyright (c) 2015-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015-2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "ViewController.h"
#import "DemoUtils.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPUtilities.h"
#import "SPSubject.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *            madeLabel;
@property (nonatomic, weak) IBOutlet UILabel *            dbCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isRunningLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isOnlineLabel;
@property (nonatomic, weak) IBOutlet UILabel *            sentCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            sessionCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isBackgroundLabel;
@property (nonatomic, weak) IBOutlet UITextField *        urlTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl * methodType;
@property (nonatomic, weak) IBOutlet UISegmentedControl * trackingOnOff;
@property (nonatomic, weak) IBOutlet UISegmentedControl * protocolType;
@property (strong, nonatomic) IBOutlet UIScrollView *     scrollView;

@end

@implementation ViewController {
    SPTracker *       _tracker;
    long long int     _madeCounter;
    long long int     _sentCounter;
    NSTimer *         _updateTimer;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setup {
    _tracker = [self getTrackerWithUrl:@"http://acme.fake.com" method:SPRequestPost];
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateMetrics) userInfo:nil repeats:YES];
    _urlTextField.delegate = self;
    [_trackingOnOff addTarget:self
                       action:@selector(action)
             forControlEvents:UIControlEventValueChanged];
}

- (IBAction) trackEvents:(id)sender {
    NSString *url = [self getCollectorUrl];
    SPRequestOptions methodType = [self getMethodType];
    SPProtocol protocolType = [self getProtocolType];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([url isEqual: @""]) {
            return;
        }
        
        // Update the Tracker
        
        // Ensures the application won't crash with a bad URL
        @try {
            [_tracker.emitter setUrlEndpoint:url];
        }
        @catch (NSException *exception) {
            return;
        }
        
        [_tracker.emitter setHttpMethod:methodType];
        [_tracker.emitter setProtocol:protocolType];
        
        // Itterate the made counter
        _madeCounter += 25;
        
        // Track all types of events!
        [DemoUtils trackAll:_tracker];
    });
}

- (void) updateMetrics {
    [_madeLabel setText:[NSString stringWithFormat:@"Made: %lld", _madeCounter]];
    [_dbCountLabel setText:[NSString stringWithFormat:@"DB Count: %lu", (unsigned long)[_tracker.emitter getDbCount]]];
    [_sessionCountLabel setText:[NSString stringWithFormat:@"Session Count: %lu", (unsigned long)[_tracker getSessionIndex]]];
    [_isRunningLabel setText:[NSString stringWithFormat:@"Running: %s", [_tracker.emitter getSendingStatus] ? "yes" : "no"]];
    [_isBackgroundLabel setText:[NSString stringWithFormat:@"Background: %s", [_tracker getInBackground] ? "yes" : "no"]];
    [_isOnlineLabel setText:[NSString stringWithFormat:@"Online: %s", [SPUtilities isOnline] ? "yes" : "no"]];
    [_sentCountLabel setText:[NSString stringWithFormat:@"Sent: %lu", (unsigned long)_sentCounter]];
}

- (void) action {
    BOOL tracking = _trackingOnOff.selectedSegmentIndex == 0 ? YES : NO;
    if (tracking && ![_tracker getIsTracking]) {
        [_tracker resumeEventTracking];
    } else if ([_tracker getIsTracking]) {
        [_tracker pauseEventTracking];
    }
}

- (NSString *) getCollectorUrl {
    return _urlTextField.text;
}

- (enum SPRequestOptions) getMethodType {
    return _methodType.selectedSegmentIndex == 0 ? SPRequestGet : SPRequestPost;
}

- (enum SPProtocol) getProtocolType {
    return _protocolType.selectedSegmentIndex == 0 ? SPHttp : SPHttps;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

static NSString *const kAppId     = @"DemoAppId";
static NSString *const kNamespace = @"DemoAppNamespace";

// Tracker Setup & Init

- (SPTracker *) getTrackerWithUrl:(NSString *)url_
                           method:(enum SPRequestOptions)method_ {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:url_];
        [builder setHttpMethod:method_];
        [builder setCallback:self];
        [builder setEmitRange:500];
        [builder setEmitThreadPoolSize:20];
        [builder setByteLimitPost:52000];
    }];
    
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setAppId:kAppId];
        [builder setTrackerNamespace:kNamespace];
        [builder setBase64Encoded:false];
        [builder setSessionContext:YES];
        [builder setSubject:subject];
    }];
    return tracker;
}

// Define Callback Functions

- (void) onSuccessWithCount:(NSInteger)successCount {
    _sentCounter += successCount;
}

- (void) onFailureWithCount:(NSInteger)failureCount successCount:(NSInteger)successCount {
    _sentCounter += successCount;
}

@end
