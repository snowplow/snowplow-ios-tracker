//
//  SPGlobalContextsConfiguration.h
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

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPGlobalContext.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlobalContextsConfigurationProtocol)
@protocol SPGlobalContextsConfigurationProtocol

@property NSMutableDictionary<NSString *, SPGlobalContext *> *contextGenerators;

/**
 * Add a GlobalContext generator to the configuration of the tracker.
 * @param tag The label identifying the generator in the tracker.
 * @param generator The GlobalContext generator.
 * @return Whether the adding operation has succeeded.
 */
- (BOOL)addWithTag:(NSString *)tag contextGenerator:(SPGlobalContext *)generator NS_SWIFT_NAME(add(tag:contextGenerator:));
/**
 * Remove a GlobalContext generator from the configuration of the tracker.
 * @param tag The label identifying the generator in the tracker.
 * @return Whether the removing operation has succeded.
 */
- (nullable SPGlobalContext *)removeWithTag:(NSString *)tag NS_SWIFT_NAME(remove(tag:));

@end

/**
 * This class allows the setup of Global Contexts which are attached to selected events.
 */
NS_SWIFT_NAME(GlobalContextsConfiguration)
@interface SPGlobalContextsConfiguration : SPConfiguration <SPGlobalContextsConfigurationProtocol>

SP_BUILDER_DECLARE(SP_ESCAPE(NSMutableDictionary<NSString *, SPGlobalContext *> *), contextGenerators)

@end

NS_ASSUME_NONNULL_END
