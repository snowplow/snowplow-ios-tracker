//
//  UIViewController+SPScreenView_SWIZZLE.m
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

#import "SPTracker.h"
#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"
#import "SPUtilities.h"
#import "UIKit/UIKit.h"
#import "UIViewController+SPScreenView_SWIZZLE.h"
#import <objc/runtime.h>

@implementation UIViewController (SPScreenView_SWIZZLE)

+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //* Then swizzle */
        Class class = [self class];

        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(SP_viewDidAppear:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void) SP_viewDidAppear:(BOOL)animated {
    [self SP_viewDidAppear:animated];

    // Construct userInfo
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewControllerClassName"] = NSStringFromClass([self class]);
    userInfo[@"topViewControllerClassName"] = NSStringFromClass([[self _SP_topViewController] class]);
    // `name` is set to snowplowId class instance variable if it exists (hence no @"id" in userInfo)
    userInfo[@"name"] = [self _SP_getViewControllerName];
    userInfo[@"type"] = [[NSNumber alloc] initWithInteger:[self _SP_getTopViewControllerType]];

    // Send notification to tracker
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SPScreenViewDidAppear"
     object:self
     userInfo:userInfo];
}

- (BOOL) _SP_validateString:(NSString *)string {
    return (string && (string.length > 0));
}

- (NSString *) _SP_getSnowplowId {
    NSString * propertyName = @"snowplowId";
    SEL selector = NSSelectorFromString(propertyName);
    BOOL propertyExists = [self respondsToSelector:selector];
    if (propertyExists) {
        id value = [self valueForKey:propertyName];
        if (value && ([value isKindOfClass:[NSString class]] || [NSStringFromClass([value class]) isEqualToString:@"Swift.String"])) {
            return value;
        }
    }
    return nil;
}

- (NSString *) _SP_getViewControllerName {
    NSString * viewControllerName = [self _SP_getViewControllerName:self];
    NSString * topViewControllerName = [self _SP_getViewControllerName:[self _SP_topViewController]];

    if ([self _SP_validateString:viewControllerName]) {
        return viewControllerName;
    } else if ([self _SP_validateString:topViewControllerName]) {
        return topViewControllerName;
    }

    return @"Unknown";
}

- (NSString *) _SP_getViewControllerName:(UIViewController *)viewController {
    // check if there's an instance variable snowplowId
    NSString * viewControllerSnowplowId = [viewController _SP_getSnowplowId];
    if ([self _SP_validateString:viewControllerSnowplowId]) {
        return viewControllerSnowplowId;
    }

    // otherwise return the class name
    NSString * viewControllerClassName = NSStringFromClass([viewController class]);
    if ([self _SP_validateString:viewControllerClassName]) {
        return viewControllerClassName;
    }

    return nil;
}

- (SPScreenType) _SP_getViewControllerType:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return SPScreenTypeNavigation;
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        return SPScreenTypeTabBar;
    } else if (viewController.presentedViewController) {
        return SPScreenTypeModal;
    } else if ([viewController isKindOfClass:[UIPageViewController class]]) {
        return SPScreenTypePageView;
    } else if ([viewController isKindOfClass:[UIPopoverPresentationController class]]) {
        return SPScreenTypePopoverPresentation;
    } else if ([viewController isKindOfClass:[UISplitViewController class]]) {
        return SPScreenTypeSplitView;
    } else {
        return SPScreenTypeDefault;
    }
}

- (SPScreenType) _SP_getTopViewControllerType {
    return [self _SP_getViewControllerType:[self _SP_topViewController]];
}

- (UIViewController *) _SP_topViewController {
    UIWindow *keyWindow = nil;
    NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }
    if (!keyWindow) {
        return nil;
    }
    return [self _SP_topViewController:keyWindow.rootViewController];
}

- (UIViewController *) _SP_topViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self _SP_topViewController:[navigationController.viewControllers lastObject]];
    }

    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self _SP_topViewController:tabController.selectedViewController];
    }

    UIViewController *presentedViewController = rootViewController.presentedViewController;
    if (presentedViewController != nil) {
        return [self _SP_topViewController:presentedViewController];
    }

    return rootViewController;
}

@end
