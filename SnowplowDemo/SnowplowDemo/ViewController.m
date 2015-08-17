//
//  ViewController.m
//  SnowplowDemo
//
//  Created by Joshua Beemster on 06/08/2015.
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DemoUtils.h"
#import "SnowplowUtils.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UILabel *            madeLabel;
@property (nonatomic, weak) IBOutlet UILabel *            dbCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isRunningLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isOnlineLabel;
@property (nonatomic, weak) IBOutlet UILabel *            sentCountLabel;
@property (nonatomic, weak) IBOutlet UITextField *        urlTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl * methodType;
@property (strong, nonatomic) IBOutlet UIScrollView *     scrollView;
@end

@implementation ViewController {
    SnowplowTracker * tracker_;
    long long int     madeCounter_;
    long long int     sentCounter_;
    NSTimer *         timer_;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setup {
    timer_ = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateMetrics) userInfo:nil repeats:YES];
    _urlTextField.delegate = self;
}

- (IBAction) trackEvents:(id)sender {
    
    // Asynchronously start the Tracking Process
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Check if we can make a Tracker
        NSString *url = [self getCollectorUrl];
        if ([url isEqual: @""]) {
            return;
        } else if (tracker_ == nil) { // If the Tracker has not been made...
            tracker_ = [self getTrackerWithUrl:url method:[self getMethodType] option:SnowplowBufferDefault];
        } else if (![tracker_.collector getSendingStatus]) { // If we are offline we can update the Tracker
            tracker_ = [self getTrackerWithUrl:url method:[self getMethodType] option:SnowplowBufferDefault];
        }
        
        // Itterate the amount of events Made
        madeCounter_ += 28;
        
        [DemoUtils trackAll:tracker_];
    });
}

- (void) updateMetrics {
    [_madeLabel setText:[NSString stringWithFormat:@"Made: %lld", madeCounter_]];
    [_dbCountLabel setText:[NSString stringWithFormat:@"DB Count: %lu", (unsigned long)[tracker_.collector getDbCount]]];
    [_isRunningLabel setText:[NSString stringWithFormat:@"Running: %s", [tracker_.collector getSendingStatus] ? "yes" : "no"]];
    [_isOnlineLabel setText:[NSString stringWithFormat:@"Online: %s", [SnowplowUtils isOnline] ? "yes" : "no"]];
    [_sentCountLabel setText:[NSString stringWithFormat:@"Sent: %lu", (unsigned long)sentCounter_]];
}

- (NSString *) getCollectorUrl {
    return _urlTextField.text;
}

- (NSString *) getMethodType {
    return _methodType.selectedSegmentIndex == 0 ? @"GET" : @"POST";
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

static NSString *const kAppId     = @"DemoAppId";
static NSString *const kNamespace = @"DemoAppNamespace";

// Tracker Setup & Init

- (SnowplowTracker *) getTrackerWithUrl:(NSString *)url_
                                 method:(NSString *)method_
                                 option:(enum SnowplowBufferOptions)option_ {
    SnowplowEmitter *emitter = [[SnowplowEmitter alloc] initWithURL:[NSURL URLWithString:url_] httpMethod:method_ bufferOption:option_ emitterCallback:self];
    SnowplowTracker *tracker = [[SnowplowTracker alloc] initWithCollector:emitter appId:kAppId base64Encoded:false namespace:kNamespace];
    return tracker;
}

// Define Callback Functions

- (void) onSuccessWithCount:(NSInteger)successCount {
    sentCounter_ += successCount;
}

- (void) onFailureWithCount:(NSInteger)failureCount successCount:(NSInteger)successCount {
    sentCounter_ += successCount;
}

@end
