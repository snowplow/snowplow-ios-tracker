//
//  SPConsentWithdrawn.h
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
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPConsentWithdrawnBuilder
 @brief The protocol for building consent withdrawn events.
 */
NS_SWIFT_NAME(ConsentWithdrawnBuilder)
@protocol SPConsentWithdrawnBuilder <SPEventBuilder>

/*!
 @brief Set the ID associated with a document for withdrawing consent.

 @param documentId The document ID.
 */
- (void) setDocumentId:(NSString *)documentId __deprecated_msg("Use `documentId` of `ConsentWithdrawn` class instead.");

/*!
 @brief Set the version of the document.

 @param version The document's version.
 */
- (void) setVersion:(NSString *)version __deprecated_msg("Use `version` of `ConsentWithdrawn` class instead.");

/*!
 @brief Set the name of the consent document.

 @param name The name of the consent document.
 */
- (void) setName:(NSString *)name __deprecated_msg("Use `name` of `ConsentWithdrawn` class instead.");

/*!
 @brief Set the description of the consent document.

 @param description The consent document description.
 */
- (void) setDescription:(NSString *)description __deprecated_msg("Use `description` of `ConsentWithdrawn` class instead.");

/*!
 @brief Set whether to withdraw all consent to tracking.

 @param all Whether all consent is to be withdrawn.
 */
- (void) setAll:(BOOL)all __deprecated_msg("Use `all` of `ConsentWithdrawn` class instead.");

/*!
 @brief Set additional documents associated to the consent withdrawn event.

 @param documents An array of associated documents.
 */
- (void) setDocuments:(NSArray<SPSelfDescribingJson *> *)documents __deprecated_msg("Use `documents` of `ConsentWithdrawn` class instead.");
@end

/*!
 @class SPConsentWithdrawn
 @brief A consent withdrawn event.
 */
NS_SWIFT_NAME(ConsentWithdrawn)
@interface SPConsentWithdrawn : SPSelfDescribingAbstract <SPConsentWithdrawnBuilder>

@property (nonatomic) BOOL all;
@property (nonatomic, nullable) NSString *documentId;
@property (nonatomic, nullable) NSString *version;
@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nullable) NSString *documentDescription;
@property (nonatomic, nullable) NSArray<SPSelfDescribingJson *> *documents;

+ (instancetype)build:(void(^)(id<SPConsentWithdrawnBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (NSArray<SPSelfDescribingJson *> *) getDocuments;

SP_BUILDER_DECLARE(BOOL, all)
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentId)
SP_BUILDER_DECLARE_NULLABLE(NSString *, version)
SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentDescription)
SP_BUILDER_DECLARE_NULLABLE(NSArray<SPSelfDescribingJson *> *, documents)

@end

NS_ASSUME_NONNULL_END
