//
// SPMessageNotification.m
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
// Copyright: Copyright © 2020 Snowplow Analytics.
// License: Apache License Version 2.0
//

#import "SPMessageNotification.h"

#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "NSDictionary+SP_TypeMethods.h"

#define SPMessageNotificationTriggerString(enum) [@[@"push", @"location", @"calendar", @"timeInterval", @"other"] objectAtIndex:enum]

@implementation SPMessageNotification

NSString * const kSPMessageNotificationSchema = @"iglu:com.snowplowanalytics.mobile/message_notification/jsonschema/1-0-0";
NSString * const kSPMessageNotificationParamAction = @"action";
NSString * const kSPMessageNotificationParamMessageNotificationAttachments = @"attachments";
NSString * const kSPMessageNotificationParamBody = @"body";
NSString * const kSPMessageNotificationParamBodyLocArgs = @"bodyLocArgs";
NSString * const kSPMessageNotificationParamBodyLocKey = @"bodyLocKey";
NSString * const kSPMessageNotificationParamCategory = @"category";
NSString * const kSPMessageNotificationParamContentAvailable = @"contentAvailable";
NSString * const kSPMessageNotificationParamGroup = @"group";
NSString * const kSPMessageNotificationParamIcon = @"icon";
NSString * const kSPMessageNotificationParamNotificationCount = @"notificationCount";
NSString * const kSPMessageNotificationParamNotificationTimestamp = @"notificationTimestamp";
NSString * const kSPMessageNotificationParamSound = @"sound";
NSString * const kSPMessageNotificationParamSubtitle = @"subtitle";
NSString * const kSPMessageNotificationParamTag = @"tag";
NSString * const kSPMessageNotificationParamThreadIdentifier = @"threadIdentifier";
NSString * const kSPMessageNotificationParamTitle = @"title";
NSString * const kSPMessageNotificationParamTitleLocArgs = @"titleLocArgs";
NSString * const kSPMessageNotificationParamTitleLocKey = @"titleLocKey";
NSString * const kSPMessageNotificationParamTrigger = @"trigger";

- (instancetype)initWithTitle:(NSString *)title
                         body:(NSString *)body
                      trigger:(SPMessageNotificationTrigger)trigger {
    if (self = [super init]) {
        _title = title;
        _body = body;
        _trigger = trigger;
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, action)
SP_BUILDER_METHOD(NSArray<SPMessageNotificationAttachment *> *, attachments)
SP_BUILDER_METHOD(NSArray<NSString *> *, bodyLocArgs)
SP_BUILDER_METHOD(NSString *, bodyLocKey)
SP_BUILDER_METHOD(NSString *, category)
SP_BUILDER_METHOD(NSNumber *, contentAvailable)
SP_BUILDER_METHOD(NSString *, group)
SP_BUILDER_METHOD(NSString *, icon)
SP_BUILDER_METHOD(NSNumber *, notificationCount)
SP_BUILDER_METHOD(NSString *, notificationTimestamp)
SP_BUILDER_METHOD(NSString *, sound)
SP_BUILDER_METHOD(NSString *, subtitle)
SP_BUILDER_METHOD(NSString *, tag)
SP_BUILDER_METHOD(NSString *, threadIdentifier)
SP_BUILDER_METHOD(NSArray<NSString *> *, titleLocArgs)
SP_BUILDER_METHOD(NSString *, titleLocKey)

// --- Tracker Methods

- (NSString *)schema {
    return kSPMessageNotificationSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_action forKey:kSPMessageNotificationParamAction];
    if (_attachments.count > 0) {
        NSMutableArray<NSDictionary<NSString *, NSObject *> *> *dictAttachments = [NSMutableArray array];
        for (SPMessageNotificationAttachment *attachment in _attachments) {
            [dictAttachments addObject:attachment.data];
        }
        [payload setValue:dictAttachments forKey:kSPMessageNotificationParamMessageNotificationAttachments];
    }
    [payload setValue:_body forKey:kSPMessageNotificationParamBody];
    if (_bodyLocArgs.count > 0) {
        [payload setValue:_bodyLocArgs forKey:kSPMessageNotificationParamBodyLocArgs];
    }
    [payload setValue:_bodyLocKey forKey:kSPMessageNotificationParamBodyLocKey];
    [payload setValue:_category forKey:kSPMessageNotificationParamCategory];
    [payload setValue:_contentAvailable forKey:kSPMessageNotificationParamContentAvailable];
    [payload setValue:_group forKey:kSPMessageNotificationParamGroup];
    [payload setValue:_icon forKey:kSPMessageNotificationParamIcon];
    [payload setValue:_notificationCount forKey:kSPMessageNotificationParamNotificationCount];
    [payload setValue:_notificationTimestamp forKey:kSPMessageNotificationParamNotificationTimestamp];
    [payload setValue:_sound forKey:kSPMessageNotificationParamSound];
    [payload setValue:_subtitle forKey:kSPMessageNotificationParamSubtitle];
    [payload setValue:_tag forKey:kSPMessageNotificationParamTag];
    [payload setValue:_threadIdentifier forKey:kSPMessageNotificationParamThreadIdentifier];
    [payload setValue:_title forKey:kSPMessageNotificationParamTitle];
    if (_titleLocArgs.count > 0) {
        [payload setValue:_titleLocArgs forKey:kSPMessageNotificationParamTitleLocArgs];
    }
    [payload setValue:_titleLocKey forKey:kSPMessageNotificationParamTitleLocKey];
    [payload setValue:SPMessageNotificationTriggerString(_trigger) forKey:kSPMessageNotificationParamTrigger];
    return payload;
}

// Convenient methods

+ (SPMessageNotification *)messageNotificationWithUserInfo:(NSDictionary *)userInfo defaultTitle:(NSString *)defaultTitle defaultBody:(NSString *)defaultBody {
    NSDictionary *aps = [userInfo sp_dictionaryForKey:@"aps" defaultValue:nil];
    if (!aps) {
        return nil;
    }
    NSDictionary *alert = [aps sp_dictionaryForKey:@"alert" defaultValue:nil];
    if (!alert) {
        return nil;
    }
    // alert fields
    NSString *title = [alert sp_stringForKey:@"title" defaultValue:defaultTitle];
    NSString *body = [alert sp_stringForKey:@"body" defaultValue:defaultBody];
    if (!title || !body) {
        return nil;
    }
    NSString *subtitle = [alert sp_stringForKey:@"subtitle" defaultValue:nil];
    NSString *launchImage = [alert sp_stringForKey:@"launch-image" defaultValue:nil];
    NSString *titleLocKey = [alert sp_stringForKey:@"title-loc-key" defaultValue:nil];
    NSArray *titleLocArgs = [alert sp_arrayForKey:@"title-loc-args" itemClass:NSString.class defaultValue:nil];
    NSString *locKey = [alert sp_stringForKey:@"loc-key" defaultValue:nil];
    NSArray *locArgs = [alert sp_arrayForKey:@"loc-args" itemClass:NSString.class defaultValue:nil];
    // aps fields
    NSNumber *badge = [aps sp_numberForKey:@"badge" defaultValue:nil];
    NSString *sound = [aps sp_stringForKey:@"sound" defaultValue:nil];
    NSNumber *contentAvailable = [aps sp_numberForKey:@"content-available" defaultValue:nil];
    NSString *category = [aps sp_stringForKey:@"category" defaultValue:nil];
    NSString *threadId = [aps sp_stringForKey:@"thread-id" defaultValue:nil];
    SPMessageNotification *event = [[SPMessageNotification alloc] initWithTitle:title body:body trigger:SPMessageNotificationTriggerPush];
    event.subtitle = subtitle;
    event.icon = launchImage;
    event.titleLocKey = titleLocKey;
    event.titleLocArgs = titleLocArgs;
    event.bodyLocKey = locKey;
    event.bodyLocArgs = locArgs;
    event.notificationCount = badge;
    event.sound = sound;
    event.contentAvailable = contentAvailable;
    event.category = category;
    event.threadIdentifier = threadId;
    return event;
}
        
@end
