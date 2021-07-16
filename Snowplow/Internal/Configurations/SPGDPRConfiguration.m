//
//  SPGDPRConfiguration.m
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

// MARK: - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

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
