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


NS_SWIFT_NAME(SubjectConfiguration.Protocol)
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

@end

NS_ASSUME_NONNULL_END
