//
//  SPPageView.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPPageView.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@implementation SPPageView {
    NSString * _pageUrl;
    NSString * _pageTitle;
    NSString * _referrer;
}

+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock {
    SPPageView* event = [SPPageView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_pageUrl length] != 0) withMessage:@"PageURL cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setPageUrl:(NSString *)pageUrl {
    _pageUrl = pageUrl;
}

- (void) setPageTitle:(NSString *)pageTitle {
    _pageTitle = pageTitle;
}

- (void) setReferrer:(NSString *)referrer {
    _referrer = referrer;
}

// --- Public Methods

- (NSString *)name {
    return kSPEventPageView;
}

- (NSDictionary *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_pageUrl forKey:kSPPageUrl];
    [payload setValue:_pageTitle forKey:kSPPageTitle];
    [payload setValue:_referrer forKey:kSPPageRefr];
    return payload;
}

- (SPPayload *) getPayload {
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:kSPEventPageView forKey:kSPEvent];
    [payload addValueToPayload:_pageUrl forKey:kSPPageUrl];
    [payload addValueToPayload:_pageTitle forKey:kSPPageTitle];
    [payload addValueToPayload:_referrer forKey:kSPPageRefr];
    return [self addDefaultParamsToPayload:payload];
}

@end
