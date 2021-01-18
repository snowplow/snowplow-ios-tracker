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

@interface SPGDPRController ()

@property (nonatomic, readwrite) SPGdprProcessingBasis basisForProcessing;
@property (nonatomic, readwrite) NSString *documentId;
@property (nonatomic, readwrite) NSString *documentVersion;
@property (nonatomic, readwrite) NSString *documentDescription;

@property SPTracker *tracker;

@end

@implementation SPGDPRController

@synthesize basisForProcessing;
@synthesize documentId;
@synthesize documentVersion;
@synthesize documentDescription;

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
    }
    return self;
}

// MARK: - Methods

- (void)resetWithBasis:(SPGdprProcessingBasis)basisForProcessing
            documentId:(NSString *)documentId
       documentVersion:(NSString *)documentVersion
   documentDescription:(NSString *)documentDescription
{
    self.basisForProcessing = basisForProcessing;
    self.documentId = documentId;
    self.documentVersion = documentVersion;
    self.documentDescription = documentDescription;
    [self.tracker setGdprContextWithBasis:basisForProcessing
                               documentId:documentId
                          documentVersion:documentVersion
                      documentDescription:documentDescription];
}

- (void)disable {
    [self.tracker disableGdprContext];
}

- (BOOL)enable {
    if (self.documentId && self.documentVersion && self.documentDescription) {
        [self.tracker enableGdprContextWithBasis:self.basisForProcessing
                                      documentId:self.documentId
                                 documentVersion:self.documentVersion
                             documentDescription:self.documentDescription];
        return YES;
    }
    return NO;
}

@end
