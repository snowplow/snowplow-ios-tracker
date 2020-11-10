//
//  SPPushNotification.h
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

@class SPNotificationContent;

NS_ASSUME_NONNULL_BEGIN

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
 @protocol SPNotificationContentBuilder
 @brief The protocol for building notification content.
 */
@protocol SPNotificationContentBuilder

/*!
 @brief Set the title.

 @param title Title displayed in notification.
 */
- (void) setTitle:(NSString *)title;

/*!
 @brief Set the subtitle.

 @param subtitle Subtitle displayed.
 */
- (void) setSubtitle:(nullable NSString *)subtitle;

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
- (void) setSound:(nullable NSString *)sound;

/*!
 @brief Set the launchImageName.

 @param name The launchImageName member of a UNNotificationContent object.
 */
- (void) setLaunchImageName:(nullable NSString *)name;

/*!
 @brief Set the UserInfo dictionary.

 @param userInfo The UserInfo dictionary of a UNNotificationContent.
 */
- (void) setUserInfo:(nullable NSDictionary *)userInfo;

/*!
 @brief Set attachments.

 @param attachments Attachments displayed with notification.
 */
- (void) setAttachments:(nullable NSArray *)attachments;
@end

/*!
 @class SPPushNotification
 @brief A push notification event.
 */
@interface SPPushNotification : SPSelfDescribing <SPPushNotificationBuilder>
+ (instancetype) build:(void(^)(id<SPPushNotificationBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

/*!
 @class SPNotificationContent
 @brief A notification content event.

 This object is used to store information that supplements a push notification event.
 */
@interface SPNotificationContent : NSObject <SPNotificationContentBuilder>

@property (nonatomic) NSDictionary *payload;

+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock;
- (NSDictionary *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
