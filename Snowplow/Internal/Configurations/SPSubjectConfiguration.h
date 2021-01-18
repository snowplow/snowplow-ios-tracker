//
//  SPSubjectConfiguration.h
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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SPConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSize : NSObject <NSCoding>

@property (readonly) NSInteger width;
@property (readonly) NSInteger height;

- initWithWidth:(NSInteger)width height:(NSInteger)height;

@end


NS_SWIFT_NAME(SubjectConfigurationProtocol)
@protocol SPSubjectConfigurationProtocol

@property (nullable) NSString *userId;
@property (nullable) NSString *networkUserId;
@property (nullable) NSString *domainUserId;
@property (nullable) NSString *useragent;
@property (nullable) NSString *ipAddress;

@property (nullable) NSString *timezone;
@property (nullable) NSString *language;

@property (nullable) SPSize *screenResolution;
@property (nullable) SPSize *screenViewPort;
@property (nullable) NSNumber *colorDepth;

@end

NS_SWIFT_NAME(SubjectConfiguration)
@interface SPSubjectConfiguration : SPConfiguration <SPSubjectConfigurationProtocol>

SP_BUILDER_DECLARE_NULLABLE(NSString *, userId)
SP_BUILDER_DECLARE_NULLABLE(NSString *, networkUserId)
SP_BUILDER_DECLARE_NULLABLE(NSString *, domainUserId)
SP_BUILDER_DECLARE_NULLABLE(NSString *, useragent)
SP_BUILDER_DECLARE_NULLABLE(NSString *, ipAddress)
SP_BUILDER_DECLARE_NULLABLE(NSString *, timezone)
SP_BUILDER_DECLARE_NULLABLE(NSString *, language)
SP_BUILDER_DECLARE_NULLABLE(SPSize *, screenResolution)
SP_BUILDER_DECLARE_NULLABLE(SPSize *, screenViewPort)
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, colorDepth)

@end

NS_ASSUME_NONNULL_END
