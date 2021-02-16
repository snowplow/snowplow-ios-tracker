//
//  SPGDPRController.m
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPGDPRController.h"
#import "SPGdprContext.h"

@interface SPGDPRController ()

@property (nonatomic) SPTracker *tracker;
@property (nonatomic) SPGdprContext *gdpr;

@end

@implementation SPGDPRController

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.gdpr = tracker.gdprContext;
    }
    return self;
}

// MARK: - Methods

- (void)resetWithBasis:(SPGdprProcessingBasis)basisForProcessing
            documentId:(nullable NSString *)documentId
       documentVersion:(nullable NSString *)documentVersion
   documentDescription:(nullable NSString *)documentDescription
{
    [self.tracker setGdprContextWithBasis:basisForProcessing
                               documentId:documentId
                          documentVersion:documentVersion
                      documentDescription:documentDescription];
    self.gdpr = self.tracker.gdprContext;
}

- (void)disable {
    [self.tracker disableGdprContext];
}

- (BOOL)isEnabled {
    return self.tracker.gdprContext != nil;
}

- (BOOL)enable {
    if (!self.gdpr) {
        return NO;
    }
    [self.tracker enableGdprContextWithBasis:self.gdpr.basis
                                  documentId:self.gdpr.documentId
                             documentVersion:self.gdpr.documentVersion
                         documentDescription:self.gdpr.documentDescription];
    return YES;
}

- (SPGdprProcessingBasis)basisForProcessing {
    return [self.gdpr basis];
}

- (NSString *)documentId {
    return [self.gdpr documentId];
}

- (NSString *)documentVersion {
    return [self.gdpr documentVersion];
}

- (NSString *)documentDescription {
    return [self.gdpr documentDescription];
}

@end
