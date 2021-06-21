//
//  SPSubjectConfigurationUpdate.m
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
