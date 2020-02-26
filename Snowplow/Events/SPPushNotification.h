//
//  SPPushNotification.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

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
 @class SPPushNotification
 @brief A push notification event.
 */
@interface SPPushNotification : SPEvent <SPPushNotificationBuilder>
+ (instancetype) build:(void(^)(id<SPPushNotificationBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

NS_ASSUME_NONNULL_END
