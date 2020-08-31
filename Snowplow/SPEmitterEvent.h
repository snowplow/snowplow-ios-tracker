//
//  SPEmitterEvent.h
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

#import "SPPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPEmitterEvent : NSObject

@property (nonatomic, readonly) SPPayload *payload;
@property (nonatomic, readonly) long long storeId;

- (instancetype)initWithPayload:(SPPayload *)payload storeId:(long long)storeId;

@end

NS_ASSUME_NONNULL_END
