//
//  SPGDPRConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPGDPRConfiguration.h"
#import "SPGdprContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPGDPRConfigurationUpdate : SPGDPRConfiguration

@property (nonatomic, nullable) SPGDPRConfiguration *sourceConfig;

@property (nonatomic) SPGdprContext *gdpr;

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL gdprUpdated;

@end

NS_ASSUME_NONNULL_END
