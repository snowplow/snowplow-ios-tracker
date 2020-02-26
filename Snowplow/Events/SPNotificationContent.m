//
//  SPNotificationContent.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPNotificationContent.h"

#import "Snowplow.h"
#import "SPUtilities.h"

@implementation SPNotificationContent {
    NSString * _title;
    NSString * _subtitle;
    NSString * _body;
    NSNumber * _badge;
    NSString * _sound;
    NSString * _launchImageName;
    NSDictionary * _userInfo;
    NSArray * _attachments;
}

+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock {
    SPNotificationContent* event = [SPNotificationContent new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_title length] != 0) withMessage:@"Title cannot be nil or empty."];
    [SPUtilities checkArgument:([_body length] != 0) withMessage:@"Body cannot be nil or empty."];
    [SPUtilities checkArgument:(_badge != nil) withMessage:@"Badge cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setTitle:(NSString *)title {
    _title = title;
}

- (void) setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
}

- (void) setBody:(NSString *)body {
    _body = body;
}

- (void) setBadge:(NSNumber *)badge {
    _badge = badge;
}

- (void) setSound:(NSString *)sound {
    _sound = sound;
}

- (void) setLaunchImageName:(NSString *)name {
    _launchImageName = name;
}

- (void) setUserInfo:(NSDictionary *)userInfo {
    _userInfo = [SPUtilities replaceHyphenatedKeysWithCamelcase:userInfo];
}

- (void) setAttachments:(NSArray *)attachments {
    _attachments = attachments;
}

// --- Public Methods

- (NSDictionary *) getPayload {
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
    if (_attachments != nil) {
        [event setObject:_attachments forKey:kSPPnAttachments];
    }

    return [[NSDictionary alloc] initWithDictionary:event copyItems:YES];
}

@end
