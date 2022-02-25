//
//  SNOWError.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/// An error event representing an exception, error or warning message in the app
@interface SNOWError : SPSelfDescribingAbstract

@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nullable) NSString *stackTrace;
@property (nonatomic, readonly) NSString *message;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMessage:(NSString *)message NS_SWIFT_NAME(init(message:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
SP_BUILDER_DECLARE_NULLABLE(NSString *, stackTrace)

@end


NS_ASSUME_NONNULL_END
