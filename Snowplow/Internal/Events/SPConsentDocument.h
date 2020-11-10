//
//  SPConsentDocument.h
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
 @protocol SPConsentDocumentBuilder
 @brief The protocol for building consent documents.
 */
@protocol SPConsentDocumentBuilder

/*!
 @brief Set the ID associated with a document that defines consent.

 @param documentId The document ID.
 */
- (void) setDocumentId:(NSString *)documentId;

/*!
 @brief Set the version of the consent document.

 @param version The version of the document.
 */
- (void) setVersion:(NSString *)version;

/*!
 @brief Set the name of the consent document.

 @param name Name of the consent document.
 */
- (void) setName:(nullable NSString *)name;

/*!
 @brief Set the description of the consent document.

 @param description The consent document description.
 */
- (void) setDescription:(nullable NSString *)description;
@end

/*!
 @class SPConsentDocument
 @brief A consent document event.
 */
@interface SPConsentDocument : NSObject <SPConsentDocumentBuilder>
+ (instancetype) build:(void(^)(id<SPConsentDocumentBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

NS_ASSUME_NONNULL_END
