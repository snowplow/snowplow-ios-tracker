//
//  SPSubjectConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPSubjectConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSubjectConfigurationUpdate : SPSubjectConfiguration

SP_DIRTYFLAG(userId)
SP_DIRTYFLAG(networkUserId)
SP_DIRTYFLAG(domainUserId)
SP_DIRTYFLAG(useragent)
SP_DIRTYFLAG(ipAddress)
SP_DIRTYFLAG(timezone)
SP_DIRTYFLAG(language)
SP_DIRTYFLAG(screenResolution)
SP_DIRTYFLAG(screenViewPort)
SP_DIRTYFLAG(colorDepth)

@end

NS_ASSUME_NONNULL_END
