//
//  SPNotificationContent.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

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
 @class SPNotificationContent
 @brief A notification content event.

 This object is used to store information that supplements a push notification event.
 */
@interface SPNotificationContent : SPEvent <SPNotificationContentBuilder>
+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock;
- (NSDictionary *) getPayload;
@end

NS_ASSUME_NONNULL_END
