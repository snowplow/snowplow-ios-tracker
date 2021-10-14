//
//  SPScreenView.h
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
//  Copyright: Copyright © 2021 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

@class SPScreenState;

NS_ASSUME_NONNULL_BEGIN

/// A screenview event.
NS_SWIFT_NAME(ScreenView)
@interface SPScreenView : SPSelfDescribingAbstract

/// Name of the screen.
@property (nonatomic, readonly) NSString *name;
/// Identifier of the screen.
@property (nonatomic, readonly) NSString *screenId;
/// Type of screen.
@property (nonatomic, nullable) NSString *type;
/// Name of the previous screen.
@property (nonatomic, nullable) NSString *previousName;
/// Identifier of the previous screen.
@property (nonatomic, nullable) NSString *previousId;
/// Type of the previous screen.
@property (nonatomic, nullable) NSString *previousType;
/// Type of transition between previous and current screen,
@property (nonatomic, nullable) NSString *transitionType;
/// Name of the ViewController subclass.
@property (nonatomic, nullable) NSString *viewControllerClassName;
/// Name of the top ViewController subclass.
@property (nonatomic, nullable) NSString *topViewControllerClassName;

- (instancetype)init NS_UNAVAILABLE;

/// Creates a screenview event.
/// @param name Name of the screen.
/// @param screenId Identifier of the screen.
- (instancetype)initWithName:(NSString *)name screenId:(nullable NSUUID *)screenId NS_SWIFT_NAME(init(name:screenId:));

/// Type of screen.
SP_BUILDER_DECLARE_NULLABLE(NSString *, type)
/// Name of the previous screen.
SP_BUILDER_DECLARE_NULLABLE(NSString *, previousName)
/// Identifier of the previous screen.
SP_BUILDER_DECLARE_NULLABLE(NSString *, previousId)
/// Type of the previous screen.
SP_BUILDER_DECLARE_NULLABLE(NSString *, previousType)
/// Type of transition between previous and current screen,
SP_BUILDER_DECLARE_NULLABLE(NSString *, transitionType)
/// Name of the ViewController subclass.
SP_BUILDER_DECLARE_NULLABLE(NSString *, viewControllerClassName)
/// Name of the top ViewController subclass.
SP_BUILDER_DECLARE_NULLABLE(NSString *, topViewControllerClassName)

@end


NS_ASSUME_NONNULL_END
