//
//  SPSessionConfigurationUpdate.m
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPSessionConfigurationUpdate.h"

@implementation SPSessionConfigurationUpdate

SP_DIRTY_GETTER(NSInteger, foregroundTimeoutInSeconds);
SP_DIRTY_GETTER(NSInteger, backgroundTimeoutInSeconds);

@end
