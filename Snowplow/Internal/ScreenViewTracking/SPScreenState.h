//
//  SPScreenViewState.h
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
//  Authors: Michael Hadam
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

/** Forward declaration for SPScreenView */
@class SPPayload;

@interface SPScreenState : NSObject <NSCopying>

/** Screenview name */
@property (nonatomic, copy, readonly) NSString * name;
/** Screen type */
@property (nonatomic, copy, readonly) NSString * type;
/** Screen ID */
@property (nonatomic, copy, readonly) NSString * screenId;
/** Screenview transition type */
@property (nonatomic, copy, readonly) NSString * transitionType;
/** Top view controller class name */
@property (nonatomic, copy, readwrite) NSString * topViewControllerClassName;
/** View controller class name */
@property (nonatomic, copy, readwrite) NSString * viewControllerClassName;

- (id) init;

/**
 * Creates a new screen state.
 * @param theName A name to identify the screen view
 * @param theType The type of the screen view
 * @param theScreenId An ID generated for the screen
 * @param theTransitionType The transition used to arrive at the screen
 * @param theTopControllerName The top view controller class name
 * @param theControllerName The view controller class name
 */
- (id) initWithName:theName type:theType screenId:theScreenId transitionType:theTransitionType topViewControllerClassName:theTopControllerName viewControllerClassName:theControllerName NS_DESIGNATED_INITIALIZER;

/**
 * Creates a new screen state.
 * @param theName A name to identify the screen view
 * @param theType The type of the screen view
 * @param theTopControllerName The top view controller class name
 * @param theControllerName The view controller class name
 */
- (id) initWithName:theName type:theType topViewControllerClassName:theTopControllerName viewControllerClassName:theControllerName;

/**
 * Creates a new screen state.
 * @param theName A name to identify the screen view
 * @param theType The type of the screen view
 * @param theScreenId An ID generated for the screen
 * @param theTransitionType The transition used to arrive at the screen
 */
- (id) initWithName:(id)theName type:(id)theType screenId:(id)theScreenId transitionType:(id)theTransitionType;

/**
 * Creates a new screen state, this is important for previous state (we don't track previous transition).
 * @param theName A name to identify the screen view
 * @param theType The type of the screen view
 * @param theScreenId A ID generated for the screen
 */
- (id) initWithName:theName type:theType screenId:theScreenId;

/**
 * Creates a new screen state, this is important for previous state (we don't track previous transition).
 * @param theName A name to identify the screen view
 * @param theScreenId A ID generated for the screen
 */
- (id) initWithName:theName screenId:theScreenId;


/**
 * Returns all non-nil values if the state is valid (e.g. name is not missing or empty string).
 */
- (SPPayload *) getValidPayload;

/**
 * Return if the state is valid.
 */
- (BOOL) isValid;

@end
