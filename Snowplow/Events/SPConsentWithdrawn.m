//
//  SPConsentWithdrawn.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
    NSArray * _documents;
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
- (void) setDocuments:(NSArray *)documents {
    for (NSObject * sdj in documents) {
        [SPUtilities checkArgument:([sdj isKindOfClass:[SPSelfDescribingJson class]])
                       withMessage:@"All documents must be SelfDescribingJson objects."];
    }
    _documents = documents;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload{
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    // set event
    [event setObject:(_all ? @YES: @NO) forKey:KSPCwAll];

    return [[SPSelfDescribingJson alloc] initWithSchema:kSPConsentWithdrawnSchema andData:event];
}

- (NSArray *) getDocuments {
    __weak __typeof__(self) weakSelf = self;
    
    // returns the result of appending document passed through {docId, version, name, description} builder arguments to _documents
    NSMutableArray * documents = [[NSMutableArray alloc] init];
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

@end

