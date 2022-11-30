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

@objc(SPPushNotification)
public class PushNotification : SelfDescribingAbstract {
    @objc
    public var date: String
    @objc
    public var action: String
    @objc
    public var trigger: String
    @objc
    public var category: String
    @objc
    public var thread: String
    @objc
    public var notification: NotificationContent?

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

    @objc
    public init(date: String, action: String, notificationTrigger trigger: UNNotificationTrigger?, category: String, thread: String, notification: NotificationContent?) {
        self.date = date
        self.action = action
        self.trigger = PushNotification.string(from: trigger)
        self.category = category
        self.thread = thread
        self.notification = notification
    }

    @objc
    public class func string(from trigger: UNNotificationTrigger?) -> String {
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

    public override var schema: String {
        return kSPPushNotificationSchema
    }

    public override var payload: [String : NSObject] {
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

@objc(SPNotificationContent)
public class NotificationContent : NSObject {
    @objc
    public var title: String
    @objc
    public var body: String
    @objc
    public var badge: NSNumber?
    @objc
    public var subtitle: String?
    @objc
    public var sound: String?
    @objc
    public var launchImageName: String?
    @objc
    public var userInfo: [String : NSObject]?
    @objc
    public var attachments: [NSObject]?

    @objc
    public init(title: String, body: String, badge: NSNumber?) {
        self.title = title
        self.body = body
        self.badge = badge
    }

    @objc
    public var payload: [String : NSObject] {
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
