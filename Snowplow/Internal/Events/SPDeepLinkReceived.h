//
// SPDeepLinkReceived.h
// Snowplow
//
// Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
// Copyright: Copyright © 2020 Snowplow Analytics.
// License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Event that represents a deep-link received in the app.
 */
NS_SWIFT_NAME(DeepLinkReceived)
@interface SPDeepLinkReceived : SPSelfDescribingAbstract

extern NSString * const kSPDeepLinkReceivedSchema;
extern NSString * const kSPDeepLinkReceivedParamReferrer;
extern NSString * const kSPDeepLinkReceivedParamUrl;

/// Referrer URL, source of this deep-link
@property (nonatomic, nullable) NSString *referrer;
/// URL in the received deep-link
@property (nonatomic, nonnull, readonly) NSString *url;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUrl:(NSString *)url;

SP_BUILDER_DECLARE_NULLABLE(NSString *, referrer)

@end


NS_ASSUME_NONNULL_END
