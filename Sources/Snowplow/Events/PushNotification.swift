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

    override var payload: [String : Any] {
        var data: [String: Any] = [
            kSPPushTrigger: trigger,
            kSPPushAction: action,
            kSPPushDeliveryDate: date,
            kSPPushCategoryId: category,
            kSPPushThreadId: thread
        ]
        if let notification = notification?.payload { data[kSPPushNotificationParam] = notification }
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
    public var userInfo: [String : Any]?
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

    var payload: [String : Any] {
        var event: [String : Any] = [:]
        event[kSPPnTitle] = title
        event[kSPPnBody] = body
        event[kSPPnBadge] = badge?.intValue
        if let subtitle = subtitle {
            event[kSPPnSubtitle] = subtitle
        }
        if let sound = sound {
            event[kSPPnSound] = sound
        }
        if let launchImageName = launchImageName {
            event[kSPPnLaunchImageName] = launchImageName
        }
        if let userInfo = userInfo {
            // modify contentAvailable value 1 and 0 to true and false to comply with schema
            if var aps = userInfo["aps"] as? [String : Any],
               let contentAvailable = aps["contentAvailable"] as? Int {

                if contentAvailable == 1 {
                    aps["contentAvailable"] = true
                } else if contentAvailable == 0 {
                    aps["contentAvailable"] = false
                }
                var newUserInfo = userInfo
                newUserInfo["aps"] = aps
                event[kSPPnUserInfo] = newUserInfo
            } else {
                event[kSPPnUserInfo] = userInfo
            }
        }
        if let attachments = attachments {
            event[kSPPnAttachments] = attachments.map { (attachment: NSObject) -> [String : Any] in
                var newAttachment: [String : Any] = [:]
                if let value = attachment.value(forKey: "identifier") {
                    newAttachment[kSPPnAttachmentId] = value
                }
                if let value = attachment.value(forKey: "URL") {
                    newAttachment[kSPPnAttachmentUrl] = value
                }
                if let value = attachment.value(forKey: "type") {
                    newAttachment[kSPPnAttachmentType] = value
                }
                return newAttachment
            }
        }
        return event // copyItems: true
    }
    
    // MARK: - Builders
    
    /// The notification's subtitle.
    @objc
    public func subtitle(_ subtitle: String?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    /// The sound played when the device receives the notification.
    @objc
    public func sound(_ sound: String?) -> Self {
        self.sound = sound
        return self
    }
    
    /// The name of the image or storyboard to use when your app launches because of the notification.
    @objc
    public func launchImageName(_ name: String?) -> Self {
        self.launchImageName = name
        return self
    }
    
    /// The custom data associated with the notification.
    @objc
    public func userInfo(_ userInfo: [String : Any]?) -> Self {
        self.userInfo = userInfo
        return self
    }
    
    /// Attachments added to the notification (they can be part of the data object).
    @objc
    public func attachments(_ attachments: [NSObject]?) -> Self {
        self.attachments = attachments
        return self
    }
}
