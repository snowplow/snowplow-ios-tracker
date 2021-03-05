//
//  SPConsentGranted.m
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPConsentGranted.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPConsentDocument.h"

@implementation SPConsentGranted {
    NSString * _documentId;
    NSString * _version;
    NSString * _name;
    NSString * _documentDescription;
    NSString * _expiry;
    NSArray<SPSelfDescribingJson *> * _documents;
}

+ (instancetype)build:(void(^)(id<SPConsentGrantedBuilder> builder))buildBlock {
    SPConsentGranted* event = [SPConsentGranted new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithExpiry:(NSString *)expiry documentId:(NSString *)documentId version:(NSString *)version {
    if (self = [super init]) {
        _expiry = expiry;
        _documentId = documentId;
        _version = version;
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_expiry != nil) withMessage:@"Expiry cannot be nil."];
    [SPUtilities checkArgument:(_documentId != nil) withMessage:@"Document ID cannot be nil."];
    [SPUtilities checkArgument:(_version != nil) withMessage:@"Version cannot be nil."];
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, name)
SP_BUILDER_METHOD(NSString *, documentDescription)
SP_BUILDER_METHOD(NSArray<SPSelfDescribingJson *> *, documents)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void) setDocumentId:(NSString *)dId {
    _documentId = dId;
}

- (void) setVersion:(NSString *)version {
    _version = version;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setDescription:(NSString *)description {
    _documentDescription = description;
}

- (void) setExpiry:(NSString *)expiry {
    _expiry = expiry;
}

- (void) setDocuments:(NSArray<SPSelfDescribingJson *> *)documents {
    _documents = documents;
}

#pragma clang diagnostic pop

// --- Public Methods

- (NSString *)schema {
    return kSPConsentGrantedSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_expiry forKey:KSPCgExpiry];
    return payload;
}

- (NSArray<SPSelfDescribingJson *> *) getDocuments {
    NSMutableArray<SPSelfDescribingJson *> *documents = [NSMutableArray<SPSelfDescribingJson *> new];

    SPConsentDocument *document = [[SPConsentDocument alloc] initWithDocumentId:_documentId version:_version];
    if (_name.length != 0) {
        document.name = _name;
    }
    if (_documentDescription != 0) {
        document.documentDescription = _documentDescription;
    }

    [documents addObject:[document getPayload]];
    if (_documents.count > 0) {
        [documents addObjectsFromArray:_documents];
    }
    return documents;
}

- (void)beginProcessingWithTracker:(SPTracker *)tracker {
    NSArray<SPSelfDescribingJson *> *documents = [self getDocuments];
    if (documents) {
        [self.contexts addObjectsFromArray:documents];  // TODO: Only the user should modify the public contexts property
    }
}

@end
