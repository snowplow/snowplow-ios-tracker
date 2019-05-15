//
//  UIViewController+SPScreenView_SWIZZLE.m
//  Snowplow
//
//  Created by Michael Hadam on 2/27/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import "SPTracker.h"
#import "SPEvent.h"
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
    @try {
        // Here we introspect to see if snowplowId exists
        // Catching an exception during KVO seems easiest outside metaprogramming
        id value = [self valueForKey:@"snowplowId"];
        if (value && ([value isKindOfClass:[NSString class]] || [NSStringFromClass([value class]) isEqualToString:@"Swift.String"])) {
            return value;
        }
    }
    @catch (NSException * e) {
        // Key did not exist
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
    return [self _SP_topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
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
