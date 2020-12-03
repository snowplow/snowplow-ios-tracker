//
//  SPSubjectConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 27/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
