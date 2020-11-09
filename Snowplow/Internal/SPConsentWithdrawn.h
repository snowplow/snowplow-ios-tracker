//
//  SPConsentWithdrawn.h
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
 @protocol SPConsentWithdrawnBuilder
 @brief The protocol for building consent withdrawn events.
 */
@protocol SPConsentWithdrawnBuilder <SPEventBuilder>

/*!
 @brief Set the ID associated with a document for withdrawing consent.

 @param documentId The document ID.
 */
- (void) setDocumentId:(NSString *)documentId;

/*!
 @brief Set the version of the document.

 @param version The document's version.
 */
- (void) setVersion:(NSString *)version;

/*!
 @brief Set the name of the consent document.

 @param name The name of the consent document.
 */
- (void) setName:(NSString *)name;

/*!
 @brief Set the description of the consent document.

 @param description The consent document description.
 */
- (void) setDescription:(NSString *)description;

/*!
 @brief Set whether to withdraw all consent to tracking.

 @param all Whether all consent is to be withdrawn.
 */
- (void) setAll:(BOOL)all;

/*!
 @brief Set additional documents associated to the consent withdrawn event.

 @param documents An array of associated documents.
 */
- (void) setDocuments:(NSArray<SPSelfDescribingJson *> *)documents;
@end

/*!
 @class SPConsentWithdrawn
 @brief A consent withdrawn event.
 */
@interface SPConsentWithdrawn : SPSelfDescribing <SPConsentWithdrawnBuilder>
+ (instancetype) build:(void(^)(id<SPConsentWithdrawnBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
- (NSArray<SPSelfDescribingJson *> *) getDocuments;
@end

NS_ASSUME_NONNULL_END
