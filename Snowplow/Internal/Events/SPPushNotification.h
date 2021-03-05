//
//  SPPushNotification.h
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

@class SPNotificationContent;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPPushNotificationBuilder
 @brief The protocol for building push notification events.
 */
NS_SWIFT_NAME(PushNotificationBuilder)
@protocol SPPushNotificationBuilder <SPEventBuilder>

/*!
 @brief Set the action.

 @param action Action taken by the user.
 */
- (void) setAction:(NSString *)action __deprecated_msg("Use initializer of `PushNotification` class instead.");

/*!
 @brief Set the delivery date.

 @param date The date the notification was delivered.
 */
- (void) setDeliveryDate:(NSString *)date __deprecated_msg("Use initializer of `PushNotification` class instead.");

/*!
 @brief Set the trigger.

 @param trigger Event trigger (i.e. push or local trigger).
 */
- (void) setTrigger:(NSString *)trigger __deprecated_msg("Use initializer of `PushNotification` class instead.");

/*!
 @brief Set the category ID.

 @param category Category Id of the notification.
 */
- (void) setCategoryIdentifier:(NSString *)category __deprecated_msg("Use initializer of `PushNotification` class instead.");

/*!
 @brief Set the thread ID.

 @param thread Thread Id of the notification.
 */
- (void) setThreadIdentifier:(NSString *)thread __deprecated_msg("Use initializer of `PushNotification` class instead.");

/*!
 @brief Set the notification content.

 @param content Notification content event.
 */
- (void) setNotification:(SPNotificationContent *)content __deprecated_msg("Use initializer of `PushNotification` class instead.");
@end

/*!
 @protocol SPNotificationContentBuilder
 @brief The protocol for building notification content.
 */
NS_SWIFT_NAME(NotificationContentBuilder)
@protocol SPNotificationContentBuilder

/*!
 @brief Set the title.

 @param title Title displayed in notification.
 */
- (void) setTitle:(NSString *)title __deprecated_msg("Use initializer of `NotificationContent` class instead.");

/*!
 @brief Set the subtitle.

 @param subtitle Subtitle displayed.
 */
- (void) setSubtitle:(nullable NSString *)subtitle __deprecated_msg("Use `subtitle` of `NotificationContent` class instead.");

/*!
 @brief Set the body.

 @param body Body message.
 */
- (void) setBody:(NSString *)body __deprecated_msg("Use `body` of `NotificationContent` class instead.");

/*!
 @brief Set the badge.

 @param badge Badge count of the app.
 */
- (void) setBadge:(NSNumber *)badge __deprecated_msg("Use `badge` of `NotificationContent` class instead.");

/*!
 @brief Set the sound.

 @param sound Name of the notification sound.
 */
- (void) setSound:(nullable NSString *)sound __deprecated_msg("Use `sound` of `NotificationContent` class instead.");

/*!
 @brief Set the launchImageName.

 @param name The launchImageName member of a UNNotificationContent object.
 */
- (void) setLaunchImageName:(nullable NSString *)name __deprecated_msg("Use `imageName` of `NotificationContent` class instead.");

/*!
 @brief Set the UserInfo dictionary.

 @param userInfo The UserInfo dictionary of a UNNotificationContent.
 */
- (void) setUserInfo:(nullable NSDictionary *)userInfo __deprecated_msg("Use `userInfo` of `NotificationContent` class instead.");

/*!
 @brief Set attachments.

 @param attachments Attachments displayed with notification.
 */
- (void) setAttachments:(nullable NSArray *)attachments __deprecated_msg("Use `attachments` of `NotificationContent` class instead.");
@end

/*!
 @class SPPushNotification
 @brief A push notification event.
 */
NS_SWIFT_NAME(PushNotification)
@interface SPPushNotification : SPSelfDescribingAbstract <SPPushNotificationBuilder>

+ (instancetype)build:(void(^)(id<SPPushNotificationBuilder> builder))buildBlock;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDate:(NSString *)date action:(NSString *)action trigger:(NSString *)trigger category:(NSString *)category thread:(NSString *)thread notification:(SPNotificationContent *)notification NS_SWIFT_NAME(init(date:action:trigger:category:thread:notification:));

@end

/*!
 @class SPNotificationContent
 @brief A notification content event.

 This object is used to store information that supplements a push notification event.
 */
NS_SWIFT_NAME(NotificationContent)
@interface SPNotificationContent : NSObject <SPNotificationContentBuilder>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSNumber *badge;
@property (nonatomic, nullable) NSString *subtitle;
@property (nonatomic, nullable) NSString *sound;
@property (nonatomic, nullable) NSString *launchImageName;
@property (nonatomic, nullable) NSDictionary *userInfo;
@property (nonatomic, nullable) NSArray *attachments;

@property (nonatomic) NSDictionary *payload;

+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body badge:(NSNumber *)badge NS_SWIFT_NAME(init(title:body:badge:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, subtitle)
SP_BUILDER_DECLARE_NULLABLE(NSString *, sound)
SP_BUILDER_DECLARE_NULLABLE(NSString *, launchImageName)
SP_BUILDER_DECLARE_NULLABLE(NSDictionary *, userInfo)
SP_BUILDER_DECLARE_NULLABLE(NSArray *, attachments)

@end

NS_ASSUME_NONNULL_END
