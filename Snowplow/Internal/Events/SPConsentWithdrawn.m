//
//  SPConsentWithdrawn.m
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPConsentWithdrawn.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"
#import "SPConsentDocument.h"

@implementation SPConsentWithdrawn {
    BOOL _all;
    NSString * _documentId;
    NSString * _version;
    NSString * _name;
    NSString * _description;
    NSArray<SPSelfDescribingJson *> * _documents;
}

+ (instancetype) build:(void(^)(id<SPConsentWithdrawnBuilder>builder))buildBlock {
    SPConsentWithdrawn* event = [SPConsentWithdrawn new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [self basePreconditions];
}

// --- Builder Methods

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
    _description = description;
}

- (void) setAll:(BOOL)all {
    _all = all;
}

// documents should be an array of consent SDJs
- (void) setDocuments:(NSArray<SPSelfDescribingJson *> *)documents {
    _documents = documents;
}

// --- Public Methods

- (NSString *)schema {
    return kSPConsentWithdrawnSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    return @{
        KSPCwAll: (_all ? @YES: @NO),
    };
}

- (SPSelfDescribingJson *) getPayload{
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    // set event
    [event setObject:(_all ? @YES: @NO) forKey:KSPCwAll];

    return [[SPSelfDescribingJson alloc] initWithSchema:kSPConsentWithdrawnSchema andData:event];
}

- (NSArray<SPSelfDescribingJson *> *)getDocuments {
    __weak __typeof__(self) weakSelf = self;
    
    // returns the result of appending document passed through {docId, version, name, description} builder arguments to _documents
    NSMutableArray<SPSelfDescribingJson *> * documents = [NSMutableArray<SPSelfDescribingJson *> new];
    SPConsentDocument * document = [SPConsentDocument build:^(id<SPConsentDocumentBuilder> builder) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;

        if (strongSelf->_documentId != nil) {
            [builder setDocumentId:strongSelf->_documentId];
        }
        if (strongSelf->_version != nil) {
            [builder setVersion:strongSelf->_version];
        }
        if ([strongSelf->_name length] != 0) {
            [builder setName:strongSelf->_name];
        }
        if ([strongSelf->_description length] != 0) {
            [builder setDescription:strongSelf->_description];
        }
    }];
    [documents addObject:[document getPayload]];
    if ([self->_documents count] > 0) {
        [documents addObjectsFromArray:self->_documents];
    }
    return documents;
}

- (void)beginProcessingWithTracker:(SPTracker *)tracker {
    NSArray<SPSelfDescribingJson *> *documents = [self getDocuments];
    if (documents) {
        [self.contexts addObjectsFromArray:documents];
    }
}

@end

