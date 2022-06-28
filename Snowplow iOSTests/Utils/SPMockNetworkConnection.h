//
//  SPMockNetworkConnection.h
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
//  Authors: Alex Benini, Matus Tomlein
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPEmitter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPMockNetworkConnection : NSObject <SPNetworkConnection>

- (instancetype)initWithRequestOption:(SPHttpMethod)httpMethod statusCode:(NSInteger)statusCode;

@property (nonatomic) NSInteger statusCode;
@property (nonatomic) SPHttpMethod httpMethod;
@property (nonatomic) NSMutableArray<NSMutableArray<SPRequestResult *> *> *previousResults;
@property (nonatomic) NSUInteger sendingCount;

@end


NS_ASSUME_NONNULL_END
