//
// SPMessageNotification.h
// Snowplow
//
// Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.
//
// Copyright: Copyright © 2021 Snowplow Analytics.
// License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"
#import "SPMessageNotificationAttachment.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MessageNotificationTrigger)
typedef NS_ENUM(NSUInteger, SPMessageNotificationTrigger) {
    SPMessageNotificationTriggerPush = 0,
    SPMessageNotificationTriggerLocation,
    SPMessageNotificationTriggerCalendar,
    SPMessageNotificationTriggerTimeInterval,
    SPMessageNotificationTriggerOther
};


/// An event that represents the reception of a push notification (or a locally generated one).
NS_SWIFT_NAME(MessageNotification)
@interface SPMessageNotification : SPSelfDescribingAbstract

extern NSString * const kSPMessageNotificationSchema;
extern NSString * const kSPMessageNotificationParamAction;
extern NSString * const kSPMessageNotificationParamMessageNotificationAttachments;
extern NSString * const kSPMessageNotificationParamBody;
extern NSString * const kSPMessageNotificationParamBodyLocArgs;
extern NSString * const kSPMessageNotificationParamBodyLocKey;
extern NSString * const kSPMessageNotificationParamCategory;
extern NSString * const kSPMessageNotificationParamContentAvailable;
extern NSString * const kSPMessageNotificationParamGroup;
extern NSString * const kSPMessageNotificationParamIcon;
extern NSString * const kSPMessageNotificationParamNotificationCount;
extern NSString * const kSPMessageNotificationParamNotificationTimestamp;
extern NSString * const kSPMessageNotificationParamSound;
extern NSString * const kSPMessageNotificationParamSubtitle;
extern NSString * const kSPMessageNotificationParamTag;
extern NSString * const kSPMessageNotificationParamThreadIdentifier;
extern NSString * const kSPMessageNotificationParamTitle;
extern NSString * const kSPMessageNotificationParamTitleLocArgs;
extern NSString * const kSPMessageNotificationParamTitleLocKey;
extern NSString * const kSPMessageNotificationParamTrigger;

/// The action associated with the notification.
@property (nonatomic, nullable) NSString *action;
/// Attachments added to the notification (they can be part of the data object).
@property (nonatomic, nullable) NSArray<SPMessageNotificationAttachment *> *attachments;
/// The notification's body.
@property (nonatomic, nonnull, readonly) NSString *body;
/// Variable string values to be used in place of the format specifiers in bodyLocArgs to use to localize the body text to the user's current localization.
@property (nonatomic, nullable) NSArray<NSString *> *bodyLocArgs;
/// The key to the body string in the app's string resources to use to localize the body text to the user's current localization.
@property (nonatomic, nullable) NSString *bodyLocKey;
/// The category associated to the notification.
@property (nonatomic, nullable) NSString *category;
/// The application is notified of the delivery of the notification if it's in the foreground or background, the app will be woken up (iOS only).
@property (nonatomic, nullable) NSNumber *contentAvailable;
/// The group which this notification is part of.
@property (nonatomic, nullable) NSString *group;
/// The icon associated to the notification (Android only).
@property (nonatomic, nullable) NSString *icon;
/// The number of items this notification represents. It's the badge number on iOS.
@property (nonatomic, nullable) NSNumber *notificationCount;
/// The time when the event of the notification occurred.
@property (nonatomic, nullable) NSString *notificationTimestamp;
/// The sound played when the device receives the notification.
@property (nonatomic, nullable) NSString *sound;
/// The notification's subtitle. (iOS only)
@property (nonatomic, nullable) NSString *subtitle;
/// An identifier similar to 'group' but usable for different purposes (Android only).
@property (nonatomic, nullable) NSString *tag;
/// An identifier similar to 'group' but usable for different purposes (iOS only).
@property (nonatomic, nullable) NSString *threadIdentifier;
/// The notification's title.
@property (nonatomic, nonnull, readonly) NSString *title;
/// Variable string values to be used in place of the format specifiers in titleLocArgs to use to localize the title text to the user's current localization.
@property (nonatomic, nullable) NSArray<NSString *> *titleLocArgs;
/// The key to the title string in the app's string resources to use to localize the title text to the user's current localization.
@property (nonatomic, nullable) NSString *titleLocKey;
/// The trigger that raised the notification message.
@property (nonatomic, readonly) SPMessageNotificationTrigger trigger;

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a Message Notification event that represents a push notification or a local notification.
 @note The custom data of the push notification have to be tracked separately in custom entities that can be attached to this event.
 @param title Title of message notification.
 @param body Body content of the message notification.
 @param trigger The trigger that raised this notification: remote notification (push), position related (location), date-time related (calendar, timeInterval) or app generated (other).
 */
- (instancetype)initWithTitle:(NSString *)title
                         body:(NSString *)body
                      trigger:(SPMessageNotificationTrigger)trigger;

/// The action associated with the notification.
SP_BUILDER_DECLARE_NULLABLE(NSString *, action)
/// Attachments added to the notification (they can be part of the data object).
SP_BUILDER_DECLARE_NULLABLE(NSArray<SPMessageNotificationAttachment *> *, attachments)
/// Variable string values to be used in place of the format specifiers in bodyLocArgs to use to localize the body text to the user's current localization.
SP_BUILDER_DECLARE_NULLABLE(NSArray<NSString *> *, bodyLocArgs)
/// The key to the body string in the app's string resources to use to localize the body text to the user's current localization.
SP_BUILDER_DECLARE_NULLABLE(NSString *, bodyLocKey)
/// The category associated to the notification.
SP_BUILDER_DECLARE_NULLABLE(NSString *, category)
/// The application is notified of the delivery of the notification if it's in the foreground or background, the app will be woken up (iOS only).
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, contentAvailable)
/// The group which this notification is part of.
SP_BUILDER_DECLARE_NULLABLE(NSString *, group)
/// The icon associated to the notification (Android only).
SP_BUILDER_DECLARE_NULLABLE(NSString *, icon)
/// The number of items this notification represents. It's the badge number on iOS.
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, notificationCount)
/// The time when the event of the notification occurred.
SP_BUILDER_DECLARE_NULLABLE(NSString *, notificationTimestamp)
/// The sound played when the device receives the notification.
SP_BUILDER_DECLARE_NULLABLE(NSString *, sound)
/// The notification's subtitle. (iOS only)
SP_BUILDER_DECLARE_NULLABLE(NSString *, subtitle)
/// An identifier similar to 'group' but usable for different purposes (Android only).
SP_BUILDER_DECLARE_NULLABLE(NSString *, tag)
/// An identifier similar to 'group' but usable for different purposes (iOS only).
SP_BUILDER_DECLARE_NULLABLE(NSString *, threadIdentifier)
/// Variable string values to be used in place of the format specifiers in titleLocArgs to use to localize the title text to the user's current localization.
SP_BUILDER_DECLARE_NULLABLE(NSArray<NSString *> *, titleLocArgs)
/// The key to the title string in the app's string resources to use to localize the title text to the user's current localization.
SP_BUILDER_DECLARE_NULLABLE(NSString *, titleLocKey)

// Convenient methods

/**
 Creates a Message Notification event from a user info object containing data from a push notification.
 @note The custom data of the push notification have to be tracked separately in custom entities that can be attached to this event.
 @param userInfo Dictionary with "aps" values got with the push notification.
 @param defaultTitle Title to set in the message notification event if the remote push notification is purely data and without title.
 @param defaultBody Body to set in the message notification event if the remote push notification is purely data and without body.
 @return A new MessageNotification event if the `userInfo` data were well formed.
 */
+ (nullable SPMessageNotification *)messageNotificationWithUserInfo:(NSDictionary *)userInfo defaultTitle:(nullable NSString *)defaultTitle defaultBody:(nullable NSString *)defaultBody;

@end

NS_ASSUME_NONNULL_END
