//
//  SPConsentGranted.h
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

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/// A consent granted event.
NS_SWIFT_NAME(ConsentGranted)
@interface SPConsentGranted : SPSelfDescribingAbstract

/// Expiration of the consent.
@property (nonatomic, readonly) NSString *expiry;
/// Identifier of the first document.
@property (nonatomic, readonly) NSString *documentId;
/// Version of the first document.
@property (nonatomic, readonly) NSString *version;
/// Name of the first document.
@property (nonatomic, nullable) NSString *name;
/// Description of the first document.
@property (nonatomic, nullable) NSString *documentDescription;
/// Other attached documents.
@property (nonatomic, nullable) NSArray<SPSelfDescribingJson *> *documents;

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a consent granted event with a first document.
 @param expiry consent expiration.
 @param documentId identifier of the first document.
 @param version version of the first document.
 */
- (instancetype)initWithExpiry:(NSString *)expiry documentId:(NSString *)documentId version:(NSString *)version NS_SWIFT_NAME(init(expiry:documentId:version:));

/// Retuns the full list of attached documents.
- (NSArray<SPSelfDescribingJson *> *)getDocuments;

/// Name of the first document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
/// Description of the first document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentDescription)
/// Other attached documents.
SP_BUILDER_DECLARE_NULLABLE(NSArray<SPSelfDescribingJson *> *, documents)

@end

NS_ASSUME_NONNULL_END
