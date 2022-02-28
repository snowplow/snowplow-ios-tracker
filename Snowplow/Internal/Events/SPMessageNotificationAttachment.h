//
// SPMessageNotificationAttachment.h
// Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
// License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Attachment object that identify an attachment in the MessageNotification
NS_SWIFT_NAME(MessageNotificationAttachment)
@interface SPMessageNotificationAttachment : NSObject

extern NSString * const kSPMessageNotificationAttachmentParamIdentifier;
extern NSString * const kSPMessageNotificationAttachmentParamType;
extern NSString * const kSPMessageNotificationAttachmentParamUrl;

@property (readonly) NSDictionary<NSString *, NSObject *> *data;

- (instancetype)init NS_UNAVAILABLE;

/// Attachments added to the notification (they can be part of the data object).
- (instancetype)initWithIdentifier:(NSString *)identifier
                              type:(NSString *)type
                               url:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
