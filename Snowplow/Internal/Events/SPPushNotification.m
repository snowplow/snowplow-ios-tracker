//
//  SPPushNotification.m
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
//  Copyright: Copyright © 2021 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPPushNotification.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"


@interface SPPushNotification ()

@property NSString *date;
@property NSString *action;
@property NSString *trigger;
@property NSString *category;
@property NSString *thread;
@property SPNotificationContent *notification;

@end

@implementation SPPushNotification

- (instancetype)initWithDate:(NSString *)date action:(NSString *)action trigger:(NSString *)trigger category:(NSString *)category thread:(NSString *)thread notification:(SPNotificationContent *)notification {
    if (self = [super init]) {
        _date = date;
        _action = action;
        _trigger = trigger;
        _category = category;
        _thread = thread;
        _notification = notification;
        [SPUtilities checkArgument:([_date length] != 0) withMessage:@"Delivery date cannot be nil or empty."];
        [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
        [SPUtilities checkArgument:([_trigger length] != 0) withMessage:@"Trigger cannot be nil or empty."];
        [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category identifier cannot be nil or empty."];
        [SPUtilities checkArgument:([_thread length] != 0) withMessage:@"Thread identifier cannot be nil or empty."];
    }
    return self;
}

#if SNOWPLOW_TARGET_IOS
- (instancetype)initWithDate:(NSString *)date action:(NSString *)action notificationTrigger:(nullable UNNotificationTrigger *)trigger category:(NSString *)category thread:(NSString *)thread notification:(SPNotificationContent *)notification {
    if (self = [super init]) {
        _date = date;
        _action = action;
        _trigger = [SPPushNotification stringFromNotificationTrigger:trigger];
        _category = category;
        _thread = thread;
        _notification = notification;
        [SPUtilities checkArgument:([_date length] != 0) withMessage:@"Delivery date cannot be nil or empty."];
        [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
        [SPUtilities checkArgument:([_trigger length] != 0) withMessage:@"Trigger cannot be nil or empty."];
        [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category identifier cannot be nil or empty."];
        [SPUtilities checkArgument:([_thread length] != 0) withMessage:@"Thread identifier cannot be nil or empty."];
    }
    return self;
}


+ (NSString *)stringFromNotificationTrigger:(nullable UNNotificationTrigger *)trigger  API_AVAILABLE(ios(10.0)) {
    NSMutableString * triggerType = [[NSMutableString alloc] initWithString:@"UNKNOWN"];
    NSString * triggerClass = NSStringFromClass([trigger class]);
    if ([triggerClass isEqualToString:@"UNTimeIntervalNotificationTrigger"]) {
        [triggerType setString:@"TIME_INTERVAL"];
    } else if ([triggerClass isEqualToString:@"UNCalendarNotificationTrigger"]) {
        [triggerType setString:@"CALENDAR"];
    } else if ([triggerClass isEqualToString:@"UNLocationNotificationTrigger"]) {
        [triggerType setString:@"LOCATION"];
    } else if ([triggerClass isEqualToString:@"UNPushNotificationTrigger"]) {
        [triggerType setString:@"PUSH"];
    }
    return (NSString *)triggerType;
}
#endif

// MARK: - Public Methods

- (NSString *)schema {
    return kSPPushNotificationSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    return @{
        kSPPushNotification: _notification.payload,
        kSPPushTrigger: _trigger,
        kSPPushAction: _action,
        kSPPushDeliveryDate: _date,
        kSPPushCategoryId: _category,
        kSPPushThreadId: _thread,
    };
}

@end


// MARK:- SPNotificationContent

@interface SPNotificationContent ()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *body;
@property (nonatomic, readwrite) NSNumber *badge;

@end

@implementation SPNotificationContent

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body badge:(NSNumber *)badge {
    if (self = [super init]) {
        _title = title;
        _body = body;
        _badge = badge;
        [SPUtilities checkArgument:([_title length] != 0) withMessage:@"Title cannot be nil or empty."];
        [SPUtilities checkArgument:([_body length] != 0) withMessage:@"Body cannot be nil or empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, subtitle)
SP_BUILDER_METHOD(NSString *, sound)
SP_BUILDER_METHOD(NSString *, launchImageName)
SP_BUILDER_METHOD(NSDictionary *, userInfo)
SP_BUILDER_METHOD(NSArray *, attachments)

// --- Public Methods

- (NSDictionary *)payload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_title forKey:kSPPnTitle];
    [event setObject:_body forKey:kSPPnBody];
    [event setValue:_badge forKey:kSPPnBadge];
    if (_subtitle != nil) {
        [event setObject:_subtitle forKey:kSPPnSubtitle];
    }
    if (_subtitle != nil) {
        [event setObject:_subtitle forKey:kSPPnSubtitle];
    }
    if (_sound != nil) {
        [event setObject:_sound forKey:kSPPnSound];
    }
    if (_launchImageName != nil) {
        [event setObject:_launchImageName forKey:kSPPnLaunchImageName];
    }
    if (_userInfo != nil) {
        NSMutableDictionary * aps = nil;
        NSMutableDictionary * newUserInfo = nil;

        // modify contentAvailable value "1" and "0" to @YES and @NO to comply with schema
        if (![[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:nil] &&
            [[_userInfo objectForKey:@"aps"] isKindOfClass:[NSDictionary class]]) {
            aps = [[NSMutableDictionary alloc] initWithDictionary:_userInfo[@"aps"]];

            if ([[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:@1]) {
                [aps setObject:@YES forKey:@"contentAvailable"];
            } else if ([[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:@0]) {
                [aps setObject:@NO forKey:@"contentAvailable"];
            }
            newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:_userInfo];
            [newUserInfo setObject:aps forKey:@"aps"];
        }
        [event setObject:[[NSDictionary alloc] initWithDictionary:newUserInfo] forKey:kSPPnUserInfo];
    }
    if (_attachments.count) {
        NSMutableArray<NSDictionary *> * converting = [[NSMutableArray alloc] init];
        NSMutableDictionary * newAttachment = [[NSMutableDictionary alloc] init];
        for (id attachment in _attachments) {
            newAttachment[kSPPnAttachmentId] = [attachment valueForKey:@"identifier"];
            newAttachment[kSPPnAttachmentUrl] = [attachment valueForKey:@"URL"];
            newAttachment[kSPPnAttachmentType] = [attachment valueForKey:@"type"];
            [converting addObject: (NSDictionary *)[newAttachment copy]];
            [newAttachment removeAllObjects];
        }
        [event setObject:[NSArray arrayWithArray:converting] forKey:kSPPnAttachments];
    }
    return [[NSDictionary alloc] initWithDictionary:event copyItems:YES];
}

@end
