//
// SPMessageNotificationAttachment.m
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

#import "SPMessageNotificationAttachment.h"


@interface SPMessageNotificationAttachment ()

@property NSMutableDictionary<NSString *, NSObject *> *dictionary;

@end


@implementation SPMessageNotificationAttachment

NSString * const kSPMessageNotificationAttachmentParamIdentifier = @"identifier";
NSString * const kSPMessageNotificationAttachmentParamType = @"type";
NSString * const kSPMessageNotificationAttachmentParamUrl = @"url";

- (instancetype)initWithIdentifier:(NSString *)identifier
                              type:(NSString *)type
                               url:(NSString *)url {
    if (self = [super init]) {
        self.dictionary = [[NSMutableDictionary alloc] init];
        [self.dictionary setObject:identifier forKey:kSPMessageNotificationAttachmentParamIdentifier];
        [self.dictionary setObject:type forKey:kSPMessageNotificationAttachmentParamType];
        [self.dictionary setObject:url forKey:kSPMessageNotificationAttachmentParamUrl];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)data {
    return [self.dictionary copy];
}

@end
