//
//  SPPushNotification.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

#if SNOWPLOW_TARGET_IOS
#import <UserNotifications/UserNotifications.h>
#endif

@class SPNotificationContent;

NS_ASSUME_NONNULL_BEGIN

/*!
 A push notification event.
 @deprecated This is available only on iOS. Please, use MessageNotification instead, which is available for both iOS and Android trackers.
 */
NS_SWIFT_NAME(PushNotification)
@interface SPPushNotification : SPSelfDescribingAbstract

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDate:(NSString *)date action:(NSString *)action trigger:(NSString *)trigger category:(NSString *)category thread:(NSString *)thread notification:(SPNotificationContent *)notification NS_SWIFT_NAME(init(date:action:trigger:category:thread:notification:));

#if SNOWPLOW_TARGET_IOS
- (instancetype)initWithDate:(NSString *)date action:(NSString *)action notificationTrigger:(nullable UNNotificationTrigger *)trigger category:(NSString *)category thread:(NSString *)thread notification:(SPNotificationContent *)notification NS_SWIFT_NAME(init(date:action:notificationTrigger:category:thread:notification:)) NS_AVAILABLE_IOS(10.0);
#endif

@end

/*!
 A notification content event. This object is used to store information that supplements a push notification event.
 @deprecated This is available only on iOS. Please, use MessageNotification instead, which is available for both iOS and Android trackers.
 */
NS_SWIFT_NAME(NotificationContent)
@interface SPNotificationContent : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSNumber *badge;
@property (nonatomic, nullable) NSString *subtitle;
@property (nonatomic, nullable) NSString *sound;
@property (nonatomic, nullable) NSString *launchImageName;
@property (nonatomic, nullable) NSDictionary *userInfo;
@property (nonatomic, nullable) NSArray *attachments;

@property (nonatomic) NSDictionary *payload;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body badge:(NSNumber *)badge NS_SWIFT_NAME(init(title:body:badge:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, subtitle)
SP_BUILDER_DECLARE_NULLABLE(NSString *, sound)
SP_BUILDER_DECLARE_NULLABLE(NSString *, launchImageName)
SP_BUILDER_DECLARE_NULLABLE(NSDictionary *, userInfo)
SP_BUILDER_DECLARE_NULLABLE(NSArray *, attachments)

@end

NS_ASSUME_NONNULL_END
