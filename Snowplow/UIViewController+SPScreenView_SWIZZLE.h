//
//  UIViewController+SPScreenView.h
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
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//  License: Apache License Version 2.0
//

#import <UIKit/UIKit.h>

@class UIViewController;
typedef NS_ENUM(NSInteger, SPScreenType);

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SPScreenView_SWIZZLE)

- (void) SP_viewDidAppear:(BOOL)animated;
- (NSString *) _SP_getViewControllerName:(UIViewController *)viewController;
- (SPScreenType) _SP_getViewControllerType:(UIViewController *)viewController;
- (SPScreenType) _SP_getTopViewControllerType;
- (UIViewController *) _SP_topViewController;
- (UIViewController *) _SP_topViewController:(UIViewController *)rootViewController;
- (NSString *) _SP_getViewControllerName;
- (BOOL) _SP_validateString:(NSString *)string;
- (NSString *) _SP_getSnowplowId;

@end

NS_ASSUME_NONNULL_END
