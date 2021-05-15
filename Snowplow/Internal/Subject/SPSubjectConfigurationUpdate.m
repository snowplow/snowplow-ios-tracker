//
//  SPSubjectConfigurationUpdate.m
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPSubjectConfigurationUpdate.h"

@implementation SPSubjectConfigurationUpdate

SP_DIRTY_GETTER(NSString *, userId)
SP_DIRTY_GETTER(NSString *, networkUserId)
SP_DIRTY_GETTER(NSString *, domainUserId)
SP_DIRTY_GETTER(NSString *, useragent)
SP_DIRTY_GETTER(NSString *, ipAddress)
SP_DIRTY_GETTER(NSString *, timezone)
SP_DIRTY_GETTER(NSString *, language)
SP_DIRTY_GETTER(SPSize *, screenResolution)
SP_DIRTY_GETTER(SPSize *, screenViewPort)
SP_DIRTY_GETTER(NSNumber *, colorDepth)

@end
