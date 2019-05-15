//
//  UIViewController+SPScreenView.h
//  Snowplow
//
//  Created by Michael Hadam on 2/27/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

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
