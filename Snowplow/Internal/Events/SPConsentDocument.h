//
//  SPConsentDocument.h
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

#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPConsentDocumentBuilder
 @brief The protocol for building consent documents.
 */
NS_SWIFT_NAME(ConsentDocumentBuilder)
@protocol SPConsentDocumentBuilder

/*!
 @brief Set the ID associated with a document that defines consent.

 @param documentId The document ID.
 */
- (void) setDocumentId:(NSString *)documentId __deprecated_msg("Use initializer of `ConsentDocument` class instead.");

/*!
 @brief Set the version of the consent document.

 @param version The version of the document.
 */
- (void) setVersion:(NSString *)version __deprecated_msg("Use `version` of `ConsentDocument` class instead.");

/*!
 @brief Set the name of the consent document.

 @param name Name of the consent document.
 */
- (void) setName:(nullable NSString *)name __deprecated_msg("Use `name` of `ConsentDocument` class instead.");

/*!
 @brief Set the description of the consent document.

 @param description The consent document description.
 */
- (void) setDescription:(nullable NSString *)description __deprecated_msg("Use `description` of `ConsentDocument` class instead.");
@end

/*!
 @class SPConsentDocument
 @brief A consent document event.
 */
NS_SWIFT_NAME(ConsentDocument)
@interface SPConsentDocument : NSObject <SPConsentDocumentBuilder>

@property (nonatomic, readonly) NSString *documentId;
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nullable) NSString *documentDescription;

+ (instancetype)build:(void(^)(id<SPConsentDocumentBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDocumentId:(NSString *)documentId version:(NSString *)version NS_SWIFT_NAME(init(documentId:version:));

- (SPSelfDescribingJson *) getPayload;

SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentDescription)

@end

NS_ASSUME_NONNULL_END
