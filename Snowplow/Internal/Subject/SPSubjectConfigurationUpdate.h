//
//  SPSubjectConfigurationUpdate.h
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

NS_ASSUME_NONNULL_BEGIN

@interface SPSubjectConfigurationUpdate : SPSubjectConfiguration

@property (nonatomic, nullable) SPSubjectConfiguration *sourceConfig;

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
