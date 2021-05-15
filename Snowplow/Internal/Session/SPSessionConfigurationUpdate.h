//
//  SPSessionConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPSessionConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSessionConfigurationUpdate : SPSessionConfiguration

@property (nonatomic) BOOL isPaused;

SP_DIRTYFLAG(foregroundTimeoutInSeconds)
SP_DIRTYFLAG(backgroundTimeoutInSeconds)

@end

NS_ASSUME_NONNULL_END
