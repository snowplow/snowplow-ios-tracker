//
//  SPConsentWithdrawn.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

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
- (void) setDocuments:(NSArray *)documents;
@end

/*!
 @class SPConsentWithdrawn
 @brief A consent withdrawn event.
 */
@interface SPConsentWithdrawn : SPEvent <SPConsentWithdrawnBuilder>
+ (instancetype) build:(void(^)(id<SPConsentWithdrawnBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
- (NSArray *) getDocuments;
@end

NS_ASSUME_NONNULL_END
