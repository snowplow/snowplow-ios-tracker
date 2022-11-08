//
// SPDeepLinkEntity.h
// Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.
//
// License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Entity that indicates a deep-link has been received and processed.
 */
NS_SWIFT_NAME(DeepLinkEntity)
@interface SPDeepLinkEntity : SPSelfDescribingJson

extern NSString * const kSPDeepLinkSchema;
extern NSString * const kSPDeepLinkParamReferrer;
extern NSString * const kSPDeepLinkParamUrl;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUrl:(NSString *)url;

SP_BUILDER_DECLARE_NULLABLE(NSString *, referrer)

@end


NS_ASSUME_NONNULL_END
