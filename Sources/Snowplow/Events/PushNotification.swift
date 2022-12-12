//  PushNotification.swift
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation
#if os(iOS)
import UserNotifications
#endif

/// Push notification event.
///
/// Schema: `iglu:com.apple/notification_event/jsonschema/1-0-1`
@objc(SPPushNotification)
public class PushNotification : SelfDescribingAbstract {
    /// The delivery date of the notification.
    @objc
    public var date: String
    /// The action associated with the notification.
    @objc
    public var action: String
    /// The trigger that raised this notification: remote notification (`PUSH`), position related (`LOCATION`), date-time related (`CALENDAR`, `TIME_INTERVAL`).
    @objc
    public var trigger: String
    /// The category associated to the notification.
    @objc
    public var category: String
    /// An identifier for the thread.
    @objc
    public var thread: String
    /// Notification content
    @objc
    public var notification: NotificationContent?

    /// Creates a notification event
    /// - Parameter date: The delivery date of the notification.
    /// - Parameter action: The action associated with the notification.
    /// - Parameter trigger: The trigger that raised this notification: remote notification (`PUSH`), position related (`LOCATION`), date-time related (`CALENDAR`, `TIME_INTERVAL`).
    /// - Parameter category: The category associated to the notification.
    /// - Parameter thread: An identifier for the thread.
    /// - Parameter notification: Notification content.
    @objc
    public init(date: String, action: String, trigger: String, category: String, thread: String, notification: NotificationContent?) {
        self.date = date
        self.action = action
        self.trigger = trigger
        self.category = category
        self.thread = thread
        self.notification = notification
    }

    #if os(iOS)

    /// Creates a notification event
    /// - Parameter date: The delivery date of the notification.
    /// - Parameter action: The action associated with the notification.
    /// - Parameter notificationTrigger: The trigger that raised this notification: remote notification (`PUSH`), position related (`LOCATION`), date-time related (`CALENDAR`, `TIME_INTERVAL`).
    /// - Parameter category: The category associated to the notification.
    /// - Parameter thread: An identifier for the thread.
    /// - Parameter notification: Notification content.
    @objc
    public init(date: String, action: String, notificationTrigger trigger: UNNotificationTrigger?, category: String, thread: String, notification: NotificationContent?) {
        self.date = date
        self.action = action
        self.trigger = PushNotification.string(from: trigger)
        self.category = category
        self.thread = thread
        self.notification = notification
    }

    class func string(from trigger: UNNotificationTrigger?) -> String {
        var triggerType = "UNKNOWN"
        if let trigger = trigger {
            let triggerClass = NSStringFromClass(type(of: trigger).self)
            if triggerClass == "UNTimeIntervalNotificationTrigger" {
                triggerType = "TIME_INTERVAL"
            } else if triggerClass == "UNCalendarNotificationTrigger" {
                triggerType = "CALENDAR"
            } else if triggerClass == "UNLocationNotificationTrigger" {
                triggerType = "LOCATION"
            } else if triggerClass == "UNPushNotificationTrigger" {
                triggerType = "PUSH"
            }
        }
        return triggerType
    }

    #endif

    override var schema: String {
        return kSPPushNotificationSchema
    }

    override var payload: [String : NSObject] {
        var data: [String: NSObject] = [
            kSPPushTrigger: trigger as NSObject,
            kSPPushAction: action as NSObject,
            kSPPushDeliveryDate: date as NSObject,
            kSPPushCategoryId: category as NSObject,
            kSPPushThreadId: thread as NSObject
        ]
        if let notification = notification?.payload { data[kSPPushNotificationParam] = notification as NSObject }
        return data
    }
}

// MARK:- SPNotificationContent

/// Content for a notification.
@objc(SPNotificationContent)
public class NotificationContent : NSObject {
    /// Title of message notification.
    @objc
    public var title: String
    /// Body content of the message notification.
    @objc
    public var body: String
    /// The number that the app’s icon displays.
    @objc
    public var badge: NSNumber?
    /// The notification's subtitle.
    @objc
    public var subtitle: String?
    /// The sound played when the device receives the notification.
    @objc
    public var sound: String?
    /// The name of the image or storyboard to use when your app launches because of the notification.
    @objc
    public var launchImageName: String?
    /// The custom data associated with the notification.
    @objc
    public var userInfo: [String : NSObject]?
    /// Attachments added to the notification (they can be part of the data object).
    @objc
    public var attachments: [NSObject]?

    /// Creates a notification content
    /// - Parameter title: Title of message notification.
    /// - Parameter body: Body content of the message notification.
    /// - Parameter badge: The number that the app’s icon displays.
    @objc
    public init(title: String, body: String, badge: NSNumber?) {
        self.title = title
        self.body = body
        self.badge = badge
    }

    var payload: [String : NSObject] {
        var event: [String : NSObject] = [:]
        event[kSPPnTitle] = title as NSObject
        event[kSPPnBody] = body as NSObject
        event[kSPPnBadge] = badge
        if let subtitle = subtitle {
            event[kSPPnSubtitle] = subtitle as NSObject
        }
        if let sound = sound {
            event[kSPPnSound] = sound as NSObject
        }
        if let launchImageName = launchImageName {
            event[kSPPnLaunchImageName] = launchImageName as NSObject
        }
        if let userInfo = userInfo {
            // modify contentAvailable value "1" and "0" to @YES and @NO to comply with schema
            if var aps = userInfo["aps"] as? [NSString : NSObject],
               let contentAvailable = aps["contentAvailable"] as? NSNumber {

                if contentAvailable == NSNumber(value: 1) {
                    aps["contentAvailable"] = NSNumber(value: true)
                } else if contentAvailable == NSNumber(value: 0) {
                    aps["contentAvailable"] = NSNumber(value: false)
                }
                var newUserInfo = userInfo
                newUserInfo["aps"] = aps as NSObject
                event[kSPPnUserInfo] = newUserInfo as NSObject
            }
        }
        if let attachments = attachments {
            var converting: [[AnyHashable : Any]] = []
            for attachment in attachments {
                var newAttachment: [String : NSObject] = [:]
                if let value = attachment.value(forKey: "identifier") as? NSObject {
                    newAttachment[kSPPnAttachmentId] = value
                }
                if let value = attachment.value(forKey: "URL") as? NSObject {
                    newAttachment[kSPPnAttachmentUrl] = value
                }
                if let value = attachment.value(forKey: "type") as? NSObject {
                    newAttachment[kSPPnAttachmentType] = value
                }
                converting.append(newAttachment)
            }
            event[kSPPnAttachments] = converting as NSObject
        }
        return event // copyItems: true
    }
}
