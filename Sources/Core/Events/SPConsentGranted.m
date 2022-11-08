//
//  SPConsentGranted.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPConsentGranted.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPConsentDocument.h"

@interface SPConsentGranted ()

@property (nonatomic, readwrite) NSString *expiry;
@property (nonatomic, readwrite) NSString *documentId;
@property (nonatomic, readwrite) NSString *version;

@end

@implementation SPConsentGranted

- (instancetype)initWithExpiry:(NSString *)expiry documentId:(NSString *)documentId version:(NSString *)version {
    if (self = [super init]) {
        _expiry = expiry;
        _documentId = documentId;
        _version = version;
        [SPUtilities checkArgument:(_expiry != nil) withMessage:@"Expiry cannot be nil."];
        [SPUtilities checkArgument:(_documentId != nil) withMessage:@"Document ID cannot be nil."];
        [SPUtilities checkArgument:(_version != nil) withMessage:@"Version cannot be nil."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, name)
SP_BUILDER_METHOD(NSString *, documentDescription)
SP_BUILDER_METHOD(NSArray<SPSelfDescribingJson *> *, documents)

// --- Public Methods

- (NSString *)schema {
    return kSPConsentGrantedSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_expiry forKey:KSPCgExpiry];
    return payload;
}

- (NSArray<SPSelfDescribingJson *> *)getDocuments {
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
