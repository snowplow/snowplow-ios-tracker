//
//  SPConfigurationState.h
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
//  Authors: Matus Tomlein
//  License: Apache License Version 2.0
//

#ifndef SPConfigurationState_h
#define SPConfigurationState_h

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief State of retrieved remote configuration that states where the configuration was retrieved from.
 */
typedef NS_ENUM(NSUInteger, SPConfigurationState) {
    /**
     * The default configuration was used.
     */
    SPConfigurationStateDefault,
    /**
     * The configuration was retrieved from local cache.
     */
    SPConfigurationStateCached,
    /**
     * The configuration was retrieved from the remote configuration endpoint.
     */
    SPConfigurationStateFetched,
} NS_SWIFT_NAME(ConfigurationState);

NS_ASSUME_NONNULL_END

#endif /* SPConfigurationState_h */
