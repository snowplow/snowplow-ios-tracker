//
//  SPConsentDocument.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPConsentDocument.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SPConsentDocument {
    NSString * _documentId;
    NSString * _version;
    NSString * _name;
    NSString * _description;
}

+ (instancetype) build:(void(^)(id<SPConsentDocumentBuilder>builder))buildBlock {
    SPConsentDocument* document = [SPConsentDocument new];
    if (buildBlock) { buildBlock(document); }
    [document preconditions];
    return document;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_documentId != nil) withMessage:@"Document ID cannot be nil."];
    [SPUtilities checkArgument:(_version != nil) withMessage:@"Version cannot be nil."];
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

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {

    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_documentId forKey:kSPCdId];
    [event setObject:_version forKey:kSPCdVersion];
    if ([_name length] != 0) {
        [event setObject:_name forKey:kSPCdName];
    }
    if ([_description length] != 0) {
        [event setObject:_description forKey:KSPCdDescription];
    }

    return [[SPSelfDescribingJson alloc] initWithSchema:kSPConsentDocumentSchema
                                                andData:event];
}

@end

