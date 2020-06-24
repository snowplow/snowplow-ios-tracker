//
//  AppDelegate.swift
//  SnowplowSwiftDemo
//
//  Copyright (c) 2015-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

import UIKit
import CoreData
import Foundation
import UserNotifications
import SnowplowTracker

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {

        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
            // Do something
            completionHandler()
        case UNNotificationDefaultActionIdentifier: // App was opened from notification
            NSLog("Remote notification opened app from background!")
            if let rootViewController = window?.rootViewController as? PageViewController {

                NSLog("Notification action identifier: %@", actionIdentifier)

                let request = response.notification.request
                let requestContent = request.content
                let userInfo = requestContent.userInfo
                let sound = userInfo["sound"] as? String ?? "unknown"

                let content = SPNotificationContent.build({(builder : SPNotificationContentBuilder?) -> Void in
                    builder!.setTitle(requestContent.title)
                    builder!.setSubtitle(requestContent.subtitle)
                    builder!.setBody(requestContent.body)
                    builder!.setBadge(requestContent.badge!)
                    builder!.setSound(sound)
                    builder!.setLaunchImageName(requestContent.launchImageName)
                    builder!.setUserInfo(userInfo)
                    builder!.setAttachments(SPUtilities.convert(request.content.attachments))
                })

                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                formatter.locale = Locale(identifier: "en_US")
                let dateString = formatter.string(from: response.notification.date)
                
                let event = SPPushNotification.build({(builder : SPPushNotificationBuilder?) -> Void in
                    builder!.setAction(actionIdentifier)
                    builder!.setTrigger(SPUtilities.getTriggerType(request.trigger))
                    builder!.setDeliveryDate(dateString)
                    builder!.setCategoryIdentifier(requestContent.categoryIdentifier)
                    builder!.setThreadIdentifier(requestContent.threadIdentifier)
                    builder!.setNotification(content)
                })
                
                //print(String(data: try! JSONSerialization.data(withJSONObject: event!.getPayload().getAsDictionary(), options: .prettyPrinted), encoding: .utf8 )!)
                rootViewController.tracker?.track(event)
            }
            completionHandler()
        default:
            completionHandler()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let rootViewController = window?.rootViewController as? PageViewController {
            let token = String(format: "%@", deviceToken as CVarArg).trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
            NSLog("%@", token)
            rootViewController.updateToken(token)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("%@", error.localizedDescription )
        if let rootViewController = window?.rootViewController as? PageViewController {
            rootViewController.updateToken("failed to register")
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SnowplowSwiftDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

