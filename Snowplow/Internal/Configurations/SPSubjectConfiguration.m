//
//  SPSubjectConfiguration.m
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPSubjectConfiguration.h"


@interface SPSize ()

@property (readwrite) NSInteger width;
@property (readwrite) NSInteger height;

@end

@implementation SPSize

- initWithWidth:(NSInteger)width height:(NSInteger)height {
    if (self = [super init]) {
        self.width = width;
        self.height = height;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInteger:self.width forKey:SP_STR_PROP(width)];
    [coder encodeInteger:self.height forKey:SP_STR_PROP(height)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.width = [coder decodeIntegerForKey:SP_STR_PROP(width)];
        self.height = [coder decodeIntegerForKey:SP_STR_PROP(height)];
    }
    return self;
}

@end


@implementation SPSubjectConfiguration

@synthesize userId;
@synthesize networkUserId;
@synthesize domainUserId;
@synthesize useragent;
@synthesize ipAddress;
@synthesize timezone;
@synthesize language;
@synthesize screenResolution;
@synthesize screenViewPort;
@synthesize colorDepth;

// MARK: - Builder

SP_BUILDER_METHOD(NSString *, userId)
SP_BUILDER_METHOD(NSString *, networkUserId)
SP_BUILDER_METHOD(NSString *, domainUserId)
SP_BUILDER_METHOD(NSString *, useragent)
SP_BUILDER_METHOD(NSString *, ipAddress)
SP_BUILDER_METHOD(NSString *, timezone)
SP_BUILDER_METHOD(NSString *, language)
SP_BUILDER_METHOD(SPSize *, screenResolution)
SP_BUILDER_METHOD(SPSize *, screenViewPort)
SP_BUILDER_METHOD(NSNumber *, colorDepth)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPSubjectConfiguration *copy = [[SPSubjectConfiguration allocWithZone:zone] init];
    copy.userId = self.userId;
    copy.networkUserId = self.networkUserId;
    copy.domainUserId = self.domainUserId;
    copy.useragent = self.useragent;
    copy.ipAddress = self.ipAddress;
    copy.timezone = self.timezone;
    copy.language = self.language;
    copy.screenResolution = self.screenResolution;
    copy.screenViewPort = self.screenViewPort;
    copy.colorDepth = self.colorDepth;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.userId forKey:SP_STR_PROP(userId)];
    [coder encodeObject:self.networkUserId forKey:SP_STR_PROP(networkUserId)];
    [coder encodeObject:self.domainUserId forKey:SP_STR_PROP(domainUserId)];
    [coder encodeObject:self.useragent forKey:SP_STR_PROP(useragent)];
    [coder encodeObject:self.ipAddress forKey:SP_STR_PROP(ipAddress)];
    [coder encodeObject:self.timezone forKey:SP_STR_PROP(timezone)];
    [coder encodeObject:self.language forKey:SP_STR_PROP(language)];
    [coder encodeObject:self.screenResolution forKey:SP_STR_PROP(screenResolution)];
    [coder encodeObject:self.screenViewPort forKey:SP_STR_PROP(screenViewPort)];
    [coder encodeObject:self.colorDepth forKey:SP_STR_PROP(colorDepth)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:SP_STR_PROP(userId)];
        self.networkUserId = [coder decodeObjectForKey:SP_STR_PROP(networkUserId)];
        self.domainUserId = [coder decodeObjectForKey:SP_STR_PROP(domainUserId)];
        self.useragent = [coder decodeObjectForKey:SP_STR_PROP(useragent)];
        self.ipAddress = [coder decodeObjectForKey:SP_STR_PROP(ipAddress)];
        self.timezone = [coder decodeObjectForKey:SP_STR_PROP(timezone)];
        self.language = [coder decodeObjectForKey:SP_STR_PROP(language)];
        self.screenResolution = [coder decodeObjectForKey:SP_STR_PROP(screenResolution)];
        self.screenViewPort = [coder decodeObjectForKey:SP_STR_PROP(screenViewPort)];
        self.colorDepth = [coder decodeObjectForKey:SP_STR_PROP(colorDepth)];
    }
    return self;
}

@end

