//
//  SPGdprContext.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//  License: Apache License Version 2.0
//

#import "SPGdprContext.h"
#import "Snowplow.h"

@interface SPGdprContext ()

@property (nonatomic) NSString *basis;
@property (nonatomic) NSString *documentId;
@property (nonatomic) NSString *documentVersion;
@property (nonatomic) NSString *documentDescription;

@end

@implementation SPGdprContext

- (instancetype)initWithBasis:(SPGdprProcessingBasis)basisForProcessing
                   documentId:(NSString *)documentId
              documentVersion:(NSString *)documentVersion
          documentDescription:(NSString *)documentDescription
{
    if (self = [super init]) {
        self.basis = [self stringFromProcessingBasis:basisForProcessing];
        if (!self.basis) {
            return nil;
        }
        self.documentId = documentId;
        self.documentVersion = documentVersion;
        self.documentDescription = documentDescription;
    }
    return self;
}

- (SPSelfDescribingJson *)context {
    NSMutableDictionary<NSString *, NSString *> *data = [NSMutableDictionary dictionary];
    [data setValue:self.basis forKey:kSPBasisForProcessing];
    [data setValue:self.documentId forKey:kSPDocumentId];
    [data setValue:self.documentVersion forKey:kSPDocumentVersion];
    [data setValue:self.documentDescription forKey:kSPDocumentDescription];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPGdprContextSchema andData:data];
}

#pragma mark Private methods

- (NSString *)stringFromProcessingBasis:(SPGdprProcessingBasis)basis {
    switch (basis) {
        case SPGdprProcessingBasisConsent:
            return @"consent";
        case SPGdprProcessingBasisContract:
            return @"contract";
        case SPGdprProcessingBasisLegalObligation:
            return @"legal_obligation";
        case SPGdprProcessingBasisVitalInterest:
            return @"vital_interests";
        case SPGdprProcessingBasisPublicTask:
            return @"public_task";
        case SPGdprProcessingBasisLegitimateInterests:
            return @"legitimate_interests";
        default:
            return nil;
    }
}

@end
