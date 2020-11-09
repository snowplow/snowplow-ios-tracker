//
//  SPConsentGranted.h
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

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPConsentGrantedBuilder
 @brief The protocol for building consent granted events.
 */
@protocol SPConsentGrantedBuilder <SPEventBuilder>

/*!
 @brief Set the ID of the associated consent document.

 @param documentId The associated consent document description.
 */
- (void) setDocumentId:(NSString *)documentId;

/*!
 @brief Set the version of the associated consent document.

 @param version The associated consent document version.
 */
- (void) setVersion:(NSString *)version;

/*!
 @brief Set the name of the associated consent document.

 @param name The associated consent document name.
 */
- (void) setName:(nullable NSString *)name;

/*!
 @brief Set the description of the associated consent document.

 @param description The associated consent document description.
 */
- (void) setDescription:(nullable NSString *)description;

/*!
 @brief Set the expiry of the associated consent document.

 @param expiry The associated consent document expiry.
 */
- (void) setExpiry:(nullable NSString *)expiry;

/*!
 @brief Set additional associated consent documents.

 @param documents An array of associated consent documents.
 */
- (void) setDocuments:(nullable NSArray<SPSelfDescribingJson *> *)documents;
@end

/*!
 @class SPConsentGranted
 @brief A consent granted event.
 */
@interface SPConsentGranted : SPSelfDescribing <SPConsentGrantedBuilder>
+ (instancetype) build:(void(^)(id<SPConsentGrantedBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
- (NSArray<SPSelfDescribingJson *> *) getDocuments;
@end

NS_ASSUME_NONNULL_END
