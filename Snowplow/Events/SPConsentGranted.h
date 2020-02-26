//
//  SPConsentGranted.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

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
- (void) setName:(NSString *)name;

/*!
 @brief Set the description of the associated consent document.

 @param description The associated consent document description.
 */
- (void) setDescription:(NSString *)description;

/*!
 @brief Set the expiry of the associated consent document.

 @param expiry The associated consent document expiry.
 */
- (void) setExpiry:(NSString *)expiry;

/*!
 @brief Set additional associated consent documents.

 @param documents An array of associated consent documents.
 */
- (void) setDocuments:(NSArray *)documents;
@end

/*!
 @class SPConsentGranted
 @brief A consent granted event.
 */
@interface SPConsentGranted : SPEvent <SPConsentGrantedBuilder>
+ (instancetype) build:(void(^)(id<SPConsentGrantedBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
- (NSArray *) getDocuments;
@end

NS_ASSUME_NONNULL_END
