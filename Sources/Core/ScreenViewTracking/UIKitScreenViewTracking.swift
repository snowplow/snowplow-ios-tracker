//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

class UIKitScreenViewTracking {
    private static var initialized = false

    class func setup() {
        if (initialized) { return }
        initialized = true
        
        swizzle()
    }

    private class func swizzle() {
        #if os(iOS) || os(tvOS)
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.sp_viewDidAppear(_:))
        let forClass = UIViewController.self

        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)

        var didAddMethod = false
        if let swizzledMethod = swizzledMethod {
            didAddMethod = class_addMethod(
                forClass,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod))
        }

        if didAddMethod {
            if let originalMethod = originalMethod {
                class_replaceMethod(
                    forClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod))
            }
        } else {
            if let originalMethod = originalMethod,
               let swizzledMethod = swizzledMethod {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
        #endif
    }
}

#if os(iOS) || os(tvOS)

import ObjectiveC
import UIKit

extension UIViewController {
    
    // MARK: - Method Swizzling

    @objc func sp_viewDidAppear(_ animated: Bool) {
        sp_viewDidAppear(animated)

        let bundle = Bundle(for: self.classForCoder)
        if !bundle.bundlePath.hasPrefix(Bundle.main.bundlePath) {
            // Ignore view controllers that don't start with the main bundle path
            return
        }
        
        guard let activeController = _SP_top() else { return }
        let top = _SP_topViewController(activeController)
        
        // Construct userInfo
        var userInfo: [AnyHashable : Any] = [:]
        userInfo["viewControllerClassName"] = String(describing: self.classForCoder)
        userInfo["topViewControllerClassName"] = String(describing: top.self.classForCoder)
        
        // `name` is set to snowplowId class instance variable if it exists (hence no @"id" in userInfo)
        userInfo["name"] = _SP_getName(self) ?? _SP_getName(top) ?? "Unknown"

        userInfo["type"] = NSNumber(value: _SP_getType(top).rawValue)

        // Send notification to tracker
        NotificationCenter.default.post(
            name: NSNotification.Name("SPScreenViewDidAppear"),
            object: self,
            userInfo: userInfo)
    }

    func _SP_validate(_ string: String) -> Bool {
        return string.count > 0
    }

    func _SP_getSnowplowId() -> String? {
        let propertyName = "snowplowId"
        let selector = NSSelectorFromString(propertyName)
        let propertyExists = responds(to: selector)
        if propertyExists {
            if let value = self.value(forKey: propertyName) as? String {
                return value
            }
        }
        return nil
    }

    func _SP_getName(_ viewController: UIViewController) -> String? {
        // check if there's an instance variable snowplowId
        if let viewControllerSnowplowId = viewController._SP_getSnowplowId() {
            if _SP_validate(viewControllerSnowplowId) {
                return viewControllerSnowplowId
            }
        }

        // otherwise return the class name
        let viewControllerClassName = NSStringFromClass(type(of: viewController).self)
        if _SP_validate(viewControllerClassName) {
            return viewControllerClassName
        }

        return nil
    }

    func _SP_getType(_ viewController: UIViewController) -> ScreenType {
        if viewController is UINavigationController {
            return .navigation
        }
        if viewController is UITabBarController {
            return .tabBar
        }
        if viewController.presentedViewController != nil {
            return .modal
        }
        if viewController is UIPageViewController {
            return .pageView
        }
        if viewController is UISplitViewController {
            return .splitView
        }
        // TODO: this was taken over from Obj-C, how would it ever occur?
//        if viewController is UIPopoverPresentationController {
//            return .popoverPresentation
//        }
        return .default
    }

    func _SP_top() -> UIViewController? {
       if let rootViewController = viewIfLoaded?.window?.rootViewController {
            return rootViewController
        }
        return nil
    }

    func _SP_topViewController(_ rootViewController: UIViewController) -> UIViewController {
        if let navigationController = rootViewController as? UINavigationController,
           let visible = navigationController.visibleViewController {
            return _SP_topViewController(visible)
        }

        if let tabBarController = rootViewController as? UITabBarController,
           let controller = tabBarController.selectedViewController {
            return _SP_topViewController(controller)
        }

        if let presentedViewController = rootViewController.presentedViewController {
            return _SP_topViewController(presentedViewController)
        }

        return rootViewController
    }
}

#endif
