//
//  SPConsentGranted.h
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
 @protocol SPConsentGrantedBuilder
 @brief The protocol for building consent granted events.
 */
NS_SWIFT_NAME(ConsentGrantedBuilder)
@protocol SPConsentGrantedBuilder <SPEventBuilder>

/*!
 @brief Set the ID of the associated consent document.

 @param documentId The associated consent document description.
 */
- (void) setDocumentId:(NSString *)documentId __deprecated_msg("Use initializer of `ConsentGranted` class instead.");

/*!
 @brief Set the version of the associated consent document.

 @param version The associated consent document version.
 */
- (void) setVersion:(NSString *)version __deprecated_msg("Use initializer of `ConsentGranted` class instead.");

/*!
 @brief Set the name of the associated consent document.

 @param name The associated consent document name.
 */
- (void) setName:(nullable NSString *)name __deprecated_msg("Use `name` of `ConsentGranted` class instead.");

/*!
 @brief Set the description of the associated consent document.

 @param description The associated consent document description.
 */
- (void) setDescription:(nullable NSString *)description __deprecated_msg("Use `description` of `ConsentGranted` class instead.");

/*!
 @brief Set the expiry of the associated consent document.

 @param expiry The associated consent document expiry.
 */
- (void) setExpiry:(nullable NSString *)expiry __deprecated_msg("Use `expiry` of `ConsentGranted` class instead.");

/*!
 @brief Set additional associated consent documents.

 @param documents An array of associated consent documents.
 */
- (void) setDocuments:(nullable NSArray<SPSelfDescribingJson *> *)documents __deprecated_msg("Use `documents` of `ConsentGranted` class instead.");
@end

/*!
 @class SPConsentGranted
 @brief A consent granted event.
 */
NS_SWIFT_NAME(ConsentGranted)
@interface SPConsentGranted : SPSelfDescribingAbstract <SPConsentGrantedBuilder>

@property (nonatomic, readonly) NSString *expiry;
@property (nonatomic, readonly) NSString *documentId;
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nullable) NSString *documentDescription;
@property (nonatomic, nullable) NSArray<SPSelfDescribingJson *> *documents;

+ (instancetype)build:(void(^)(id<SPConsentGrantedBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithExpiry:(NSString *)expiry documentId:(NSString *)documentId version:(NSString *)version NS_SWIFT_NAME(init(expiry:documentId:version:));

- (NSArray<SPSelfDescribingJson *> *)getDocuments;

SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentDescription)
SP_BUILDER_DECLARE_NULLABLE(NSArray<SPSelfDescribingJson *> *, documents)

@end

NS_ASSUME_NONNULL_END
