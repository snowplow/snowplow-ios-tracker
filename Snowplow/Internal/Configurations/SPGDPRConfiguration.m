//
//  SPGDPRConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPGDPRConfiguration.h"

@interface SPGDPRConfiguration ()

@property (nonatomic, readwrite) SPGdprProcessingBasis basisForProcessing;
@property (nonatomic, readwrite) NSString *documentId;
@property (nonatomic, readwrite) NSString *documentVersion;
@property (nonatomic, readwrite) NSString *documentDescription;

@end

@implementation SPGDPRConfiguration

- (instancetype)initWithBasis:(SPGdprProcessingBasis)basisForProcessing
                   documentId:(NSString *)documentId
              documentVersion:(NSString *)documentVersion
          documentDescription:(NSString *)documentDescription
{
    if (self = [super init]) {
        self.basisForProcessing = basisForProcessing;
        self.documentId = documentId;
        self.documentVersion = documentVersion;
        self.documentDescription = documentDescription;
    }
    return self;
}

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPGDPRConfiguration *copy = [[SPGDPRConfiguration allocWithZone:zone] init];
    copy.basisForProcessing = self.basisForProcessing;
    copy.documentId = self.documentId;
    copy.documentVersion = self.documentVersion;
    copy.documentDescription = self.documentDescription;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInteger:self.basisForProcessing forKey:SP_STR_PROP(basisForProcessing)];
    [coder encodeObject:self.documentId forKey:SP_STR_PROP(documentId)];
    [coder encodeObject:self.documentVersion forKey:SP_STR_PROP(documentVersion)];
    [coder encodeObject:self.documentDescription forKey:SP_STR_PROP(documentDescription)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.basisForProcessing = [coder decodeIntegerForKey:SP_STR_PROP(basisForProcessing)];
        self.documentId = [coder decodeObjectForKey:SP_STR_PROP(documentId)];
        self.documentVersion = [coder decodeObjectForKey:SP_STR_PROP(documentVersion)];
        self.documentDescription = [coder decodeObjectForKey:SP_STR_PROP(documentDescription)];
    }
    return self;
}

@end
