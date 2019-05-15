//
//  SPEvent.h
//  Snowplow
//
//  Copyright (c) 2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPScreenState;
@class SPPayload;
@class SPSelfDescribingJson;
@class SPNotificationContent;

/*!
 @brief An enum for screen types.
 */
typedef NS_ENUM(NSInteger, SPScreenType) {
    // sourced from `View Controller Catalog for iOS`
    SPScreenTypeDefault,
    SPScreenTypeNavigation,
    SPScreenTypeTabBar,
    SPScreenTypePageView,
    SPScreenTypeSplitView,
    SPScreenTypePopoverPresentation,
    SPScreenTypeModal,
    SPScreenTypeCombined
};

NSString * stringWithSPScreenType(SPScreenType screenType);

/*!
 @protocol SPEventBuilder
 @brief The base protocol for all event builders.

 This protocol defines basic functionality needed to build all events.
 */
@protocol SPEventBuilder <NSObject>

/*!
 @brief Set the timestamp of the event.

 @param timestamp The timestamp of the event in seconds (epoch time)
 */
- (void) setTimestamp:(NSNumber *)timestamp;

/*!
 @brief Set the contexts attached to the event.

 @param contexts An array of contexts (should be self-describing JSONs).
 */
- (void) setContexts:(NSMutableArray *)contexts;

/*!
 @brief Set the UUID associated with the event.

 @param eventId A UUID for the event.
 */
- (void) setEventId:(NSString *)eventId;
@end

/*!
 @protocol SPPageViewBuilder
 @brief The protocol for building pageview events.
 */
@protocol SPPageViewBuilder <SPEventBuilder>

/*!
 @brief Set the URL of the page.

 @param pageUrl The URL of the page.
 */
- (void) setPageUrl:(NSString *)pageUrl;

/*!
 @brief Set the title of the page.

 @param pageTitle The title of the page.
 */
- (void) setPageTitle:(NSString *)pageTitle;

/*!
 @brief Set the referrer of the pageview.

 @param referrer The pageview referrer.
 */
- (void) setReferrer:(NSString *)referrer;
@end

/*!
 @protocol SPStructuredBuilder
 @brief The protocol for building structured events.
 */
@protocol SPStructuredBuilder <SPEventBuilder>

/*!
 @brief Set the category of the structured event.

 @param category The category of the structured event.
 */
- (void) setCategory:(NSString *)category;

/*!
 @brief Set the action of the structured event.

 @param action The action of the structured event.
 */
- (void) setAction:(NSString *)action;

/*!
 @brief Set the label of the structured event.

 @param label The label of the structured event.
 */
- (void) setLabel:(NSString *)label;

/*!
 @brief Set the property of the structured event.

 @param property The property of the structured event.
 */
- (void) setProperty:(NSString *)property;

/*!
 @brief Set the value of the structured event.

 @param value The value of the structured event.
 */
- (void) setValue:(double)value;
@end

/*!
 @protocol SPUnstructuredBuilder
 @brief The protocol for building unstructured events.
 */
@protocol SPUnstructuredBuilder <SPEventBuilder>
/*!
 @brief Set the data field of the unstructured event.

 @param eventData A self-describing JSON of an unstructured event.
 */
- (void) setEventData:(SPSelfDescribingJson *)eventData;
@end

/*!
 @protocol SPScreenViewBuilder
 @brief The protocol for building screenview events.
 */
@protocol SPScreenViewBuilder <SPEventBuilder>
/*!
 @brief Set the name of the screen.

 @param name The name of the screen.
 */
- (void) setName:(NSString *)name;

/*!
 @brief Set the type of the screen.

 @param type The type for the screen.
 */
- (void) setType:(NSString *)type;

/*!
 @brief Set the ID of the screen.

 @param screenId The ID for the screen.
 */
- (void) setScreenId:(NSString *)screenId;

/*!
 @brief Set the name of the previous screen.

 @param name The name of the previous screen.
 */
- (void) setPreviousScreenName:(NSString *)name;

/*!
 @brief Set the type of the previous screen.

 @param type The type of the previous screen.
 */
- (void) setPreviousScreenType:(NSString *)type;

/*!
 @brief Set the ID of the previous screen.

 @param screenId The ID for the previous screen.
 */
- (void) setPreviousScreenId:(NSString *)screenId;

/*!
 @brief Set the type of the screen transition.

 @param type The type of the screen transition.
 */
- (void) setTransitionType:(NSString *)type;

- (BOOL) setWithPreviousState:(SPScreenState *)previousState;

- (BOOL) setWithCurrentState:(SPScreenState *)currentState previousState:(SPScreenState *)previousState;

- (BOOL) setWithCurrentState:(SPScreenState *)currentState;

@end

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
- (void) setAll:(BOOL *)all;

/*!
 @brief Set additional documents associated to the consent withdrawn event.

 @param documents An array of associated documents.
 */
- (void) setDocuments:(NSArray *)documents;
@end

/*!
 @protocol SPConsentDocumentBuilder
 @brief The protocol for building consent documents.
 */
@protocol SPConsentDocumentBuilder <SPEventBuilder>

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
- (void) setName:(NSString *)name;

/*!
 @brief Set the description of the consent document.

 @param description The consent document description.
 */
- (void) setDescription:(NSString *)description;
@end

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
 @protocol SPTimingBuilder
 @brief The protocol for building timing events.
 */
@protocol SPTimingBuilder <SPEventBuilder>

/*!
 @brief Set the category of the timing event.

 This is for categorizing timing variables into logical groups (e.g API calls, asset loading).

 @param category A logical group name for variables.
 */
- (void) setCategory:(NSString *)category;

/*!
 @brief Set the variable of the timing event.

 @param variable Identify the timing being recorded.
 */
- (void) setVariable:(NSString *)variable;

/*!
 @brief Set the timing.

 @param timing The number of milliseconds in elapsed time to report.
 */
- (void) setTiming:(NSInteger)timing;

/*!
 @brief Set the label.

 @param label Optional description of this timing.
 */
- (void) setLabel:(NSString *)label;
@end

/*!
 @protocol SPEcommTransactionBuilder
 @brief The protocol for building ecommerce transaction events.
 */
@protocol SPEcommTransactionBuilder <SPEventBuilder>

/*!
 @brief Set the order ID.

 @param orderId ID of the eCommerce transaction.
 */
- (void) setOrderId:(NSString *)orderId;

/*!
 @brief Set the total value.

 @param totalValue Total transaction value.
 */
- (void) setTotalValue:(double)totalValue;

/*!
 @brief Set the affiliation.

 @param affiliation Transaction affiliation.
 */
- (void) setAffiliation:(NSString *)affiliation;

/*!
 @brief Set the tax value.

 @param taxValue Transaction tax value.
 */
- (void) setTaxValue:(double)taxValue;

/*!
 @brief Set the shipping.

 @param shipping Delivery cost charged.
 */
- (void) setShipping:(double)shipping;

/*!
 @brief Set the city.

 @param city Delivery address city.
 */
- (void) setCity:(NSString *)city;

/*!
 @brief Set the state.

 @param state Delivery address state.
 */
- (void) setState:(NSString *)state;

/*!
 @brief Set the country.

 @param country Delivery address country.
 */
- (void) setCountry:(NSString *)country;

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(NSString *)currency;

/*!
 @brief Set the items.

 @param items An array of items in the transaction.
 */
- (void) setItems:(NSArray *)items;
@end

/*!
 @protocol SPEcommTransactionItemBuilder
 @brief The protocol for building ecommerce transaction item events.
 */
@protocol SPEcommTransactionItemBuilder <SPEventBuilder>

/*!
 @brief Set the item ID.

 @param itemId ID of the eCommerce transaction.
 */
- (void) setItemId:(NSString *)itemId;

/*!
 @brief Set the Sku.

 @param sku Item SKU.
 */
- (void) setSku:(NSString *)sku;

/*!
 @brief Set the price.

 @param price Item price.
 */
- (void) setPrice:(double)price;

/*!
 @brief Set the quantity.

 @param quantity Item quantity.
 */
- (void) setQuantity:(NSInteger)quantity;

/*!
 @brief Set the name.

 @param name Item name.
 */
- (void) setName:(NSString *)name;

/*!
 @brief Set the category.

 @param category Item category.
 */
- (void) setCategory:(NSString *)category;

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(NSString *)currency;
@end

/*!
 @protocol SPNotificationContentBuilder
 @brief The protocol for building notification content.
 */
@protocol SPNotificationContentBuilder <SPEventBuilder>

/*!
 @brief Set the title.

 @param title Title displayed in notification.
 */
- (void) setTitle:(NSString *)title;

/*!
 @brief Set the subtitle.

 @param subtitle Subtitle displayed.
 */
- (void) setSubtitle:(NSString *)subtitle;

/*!
 @brief Set the body.

 @param body Body message.
 */
- (void) setBody:(NSString *)body;

/*!
 @brief Set the badge.

 @param badge Badge count of the app.
 */
- (void) setBadge:(NSNumber *)badge;

/*!
 @brief Set the sound.

 @param sound Name of the notification sound.
 */
- (void) setSound:(NSString *)sound;

/*!
 @brief Set the launchImageName.

 @param name The launchImageName member of a UNNotificationContent object.
 */
- (void) setLaunchImageName:(NSString *)name;

/*!
 @brief Set the UserInfo dictionary.

 @param userInfo The UserInfo dictionary of a UNNotificationContent.
 */
- (void) setUserInfo:(NSDictionary *)userInfo;

/*!
 @brief Set attachments.

 @param attachments Attachments displayed with notification.
 */
- (void) setAttachments:(NSArray *)attachments;
@end

/*!
 @protocol SPPushNotificationBuilder
 @brief The protocol for building push notification events.
 */
@protocol SPPushNotificationBuilder <SPEventBuilder>

/*!
 @brief Set the action.

 @param action Action taken by the user.
 */
- (void) setAction:(NSString *)action;

/*!
 @brief Set the delivery date.

 @param date The date the notification was delivered.
 */
- (void) setDeliveryDate:(NSString *)date;

/*!
 @brief Set the trigger.

 @param trigger Event trigger (i.e. push or local trigger).
 */
- (void) setTrigger:(NSString *)trigger;

/*!
 @brief Set the category ID.

 @param category Category Id of the notification.
 */
- (void) setCategoryIdentifier:(NSString *)category;

/*!
 @brief Set the thread ID.

 @param thread Thread Id of the notification.
 */
- (void) setThreadIdentifier:(NSString *)thread;

/*!
 @brief Set the notification content.

 @param content Notification content event.
 */
- (void) setNotification:(SPNotificationContent *)content;
@end

/*!
 @protocol SPForegroundBuilder
 @brief The protocol for building foreground events.
 */
@protocol SPForegroundBuilder <SPEventBuilder>

/*!
 @brief Set the index of the event, a count that increments on each background and foreground.

 @param index The transition event index.
 */
- (void) setIndex:(NSNumber *)index;
@end

/*!
 @protocol SPBackgroundBuilder
 @brief The protocol for building background events.
 */
@protocol SPBackgroundBuilder <SPEventBuilder>

/*!
 @brief Set the index of the event, a count that increments on each background and foreground.

 @param index The transition event index.
 */
- (void) setIndex:(NSNumber *)index;
@end

/*!
 @protocol SPErrorBuilder
 @brief The protocol for building error events.
 */
@protocol SPErrorBuilder <SPEventBuilder>

/*!
 @brief Set the error message.
 
 @param message The error message.
 */
- (void) setMessage:(NSString *)message;

/*!
 @brief Set the exception stack trace.
 
 @param stackTrace The stack trace of the exception.
 */
- (void) setStackTrace:(NSString *)stackTrace;

/*!
 @brief Set the exception name.
 
 @param name The exception name.
 */
- (void) setName:(NSString *)name;

@end

/*!
 @class SPEvent
 @brief The base object for all events.

 This class has the basic functionality needed to represent all events.
 */
@interface SPEvent : NSObject <SPEventBuilder>

/*! The event timestamp in epoch time. */
@property (nonatomic, readwrite) NSNumber *timestamp;
/*! The contexts attached to the event. */
@property (nonatomic, readwrite, retain) NSMutableArray* contexts;
/*! The UUID that identifies the event. */
@property (nonatomic, readwrite, retain) NSString * eventId;

- (void) basePreconditions;
- (NSMutableArray *) getContexts;
- (NSNumber *) getTimestamp;
- (NSString *) getEventId;
- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb;
@end

/*!
 @class SPPageView
 @brief A pageview.
 */
@interface SPPageView : SPEvent <SPPageViewBuilder>
+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

/*!
 @class SPStructured
 @brief A structured event.
 */
@interface SPStructured : SPEvent <SPStructuredBuilder>
+ (instancetype) build:(void(^)(id<SPStructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

/*!
 @class SPUnstructured
 @brief An unstructured event.
 */
@interface SPUnstructured : SPEvent <SPUnstructuredBuilder>
+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding;
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

/*!
 @class SPConsentDocument
 @brief A consent document event.
 */
@interface SPConsentDocument : SPEvent <SPConsentDocumentBuilder>
+ (instancetype) build:(void(^)(id<SPConsentDocumentBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
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

/*!
 @class SPScreenView
 @brief A screenview event.
 */
@interface SPScreenView : SPEvent <SPScreenViewBuilder>
+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
- (SPScreenState *) getScreenState;
- (BOOL) definesPreviousState;
- (SPScreenState *) getPreviousState;
- (BOOL) setWithPreviousState:(SPScreenState *)previousState;
- (BOOL) setWithCurrentState:(SPScreenState *)currentState;
- (BOOL) setWithCurrentState:(SPScreenState *)currentState previousState:(SPScreenState *)previousState;
@end

/*!
 @class SPTiming
 @brief A timing event.
 */
@interface SPTiming : SPEvent <SPTimingBuilder>
+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

/*!
 @class SPEcommerce
 @brief An ecommerce event.
 */
@interface SPEcommerce : SPEvent <SPEcommTransactionBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
- (NSArray *) getItems;
@end

/*!
 @class SPEcommerceItem
 @brief An ecommerce item event.
 */
@interface SPEcommerceItem : SPEvent <SPEcommTransactionItemBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionItemBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

/*!
 @class SPNotificationContent
 @brief A notification content event.

 This object is used to store information that supplements a push notification event.
 */
@interface SPNotificationContent : SPEvent <SPNotificationContentBuilder>
+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock;
- (NSDictionary *) getPayload;
@end

/*!
 @class SPPushNotification
 @brief A push notification event.
 */
@interface SPPushNotification : SPEvent <SPPushNotificationBuilder>
+ (instancetype) build:(void(^)(id<SPPushNotificationBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

/*!
 @class SPForeground
 @brief A foreground transition event.
 */
@interface SPForeground : SPEvent <SPForegroundBuilder>
+ (instancetype) build:(void(^)(id<SPForegroundBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

/*!
 @class SPBackground
 @brief A background transition event.
 */
@interface SPBackground : SPEvent <SPBackgroundBuilder>
+ (instancetype) build:(void(^)(id<SPBackgroundBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

/*!
 @class SNOWError
 @brief An error event.
 */
@interface SNOWError : SPEvent <SPErrorBuilder>
+ (instancetype) build:(void(^)(id<SPErrorBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end
