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

NS_SWIFT_NAME(SubjectConfiguration)
@interface SPSubjectConfiguration : SPConfiguration

@property (nullable) NSString *userId;
@property (nullable) NSString *networkUserId;
@property (nullable) NSString *domainUserId;
@property (nullable) NSString *useragent;
@property (nullable) NSString *ipAddress;

@property (nullable) NSString *timezone;
@property (nullable) NSString *language;

// TODO: assuming that zero is like nil could be wrong in these cases.
@property () CGSize screenResolution;
@property () CGSize screenViewPort;
@property () NSInteger colorDepth;

@end

NS_ASSUME_NONNULL_END
