//
//  SPScreenViewState.h
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
//  Authors: Michael Hadam
//  Copyright: Copyright (c) 2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPStateMachineProtocol.h"

/** Forward declaration for SPScreenView */
@class SPPayload;
@protocol SPState;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ScreenState)
@interface SPScreenState : NSObject <SPState, NSCopying>

/** Screenview name */
@property (nonatomic, copy, readonly) NSString * name;
/** Screen ID */
@property (nonatomic, copy, readonly) NSString * screenId;
/** Screen type */
@property (nonatomic, copy, nullable, readonly) NSString * type;
/** Screenview transition type */
@property (nonatomic, copy, nullable, readonly) NSString * transitionType;
/** Top view controller class name */
@property (nonatomic, copy, nullable, readonly) NSString * topViewControllerClassName;
/** View controller class name */
@property (nonatomic, copy, nullable, readonly) NSString * viewControllerClassName;

/** Previous ScreenState */
@property (nonatomic, nullable) SPScreenState *previousState;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

/**
 * Creates a new screen state.
 * @param theName A name to identify the screen view
 * @param theType The type of the screen view
 * @param theScreenId An ID generated for the screen
 * @param theTransitionType The transition used to arrive at the screen
 * @param theTopControllerName The top view controller class name
 * @param theControllerName The view controller class name
 */
- (instancetype)initWithName:(NSString *)theName type:(nullable NSString *)theType screenId:(nullable NSString *)theScreenId transitionType:(nullable NSString *)theTransitionType topViewControllerClassName:(nullable NSString *)theTopControllerName viewControllerClassName:(nullable NSString *)theControllerName NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)theName type:(nullable NSString *)theType topViewControllerClassName:(nullable NSString *)theTopControllerName viewControllerClassName:(nullable NSString *)theControllerName;

- (instancetype)initWithName:(NSString *)theName type:(nullable NSString *)theType screenId:(nullable NSString *)theScreenId transitionType:(nullable NSString *)theTransitionType;

- (instancetype)initWithName:(NSString *)theName type:(nullable NSString *)theType screenId:(nullable NSString *)theScreenId;

- (instancetype)initWithName:(NSString *)theName screenId:(nullable NSString *)theScreenId;

/**
 * Returns all non-nil values if the state is valid (e.g. name is not missing or empty string).
 */
- (SPPayload *)payload;

/**
 * Return if the state is valid.
 */
- (BOOL) isValid;

@end

NS_ASSUME_NONNULL_END
