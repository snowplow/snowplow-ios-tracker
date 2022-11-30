//
// MessageNotification.m
// Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.
//
// License: Apache License Version 2.0
//

import Foundation

let kSPMessageNotificationSchema = "iglu:com.snowplowanalytics.mobile/message_notification/jsonschema/1-0-0"
let kSPMessageNotificationParamAction = "action"
let kSPMessageNotificationParamMessageNotificationAttachments = "attachments"
let kSPMessageNotificationParamBody = "body"
let kSPMessageNotificationParamBodyLocArgs = "bodyLocArgs"
let kSPMessageNotificationParamBodyLocKey = "bodyLocKey"
let kSPMessageNotificationParamCategory = "category"
let kSPMessageNotificationParamContentAvailable = "contentAvailable"
let kSPMessageNotificationParamGroup = "group"
let kSPMessageNotificationParamIcon = "icon"
let kSPMessageNotificationParamNotificationCount = "notificationCount"
let kSPMessageNotificationParamNotificationTimestamp = "notificationTimestamp"
let kSPMessageNotificationParamSound = "sound"
let kSPMessageNotificationParamSubtitle = "subtitle"
let kSPMessageNotificationParamTag = "tag"
let kSPMessageNotificationParamThreadIdentifier = "threadIdentifier"
let kSPMessageNotificationParamTitle = "title"
let kSPMessageNotificationParamTitleLocArgs = "titleLocArgs"
let kSPMessageNotificationParamTitleLocKey = "titleLocKey"
let kSPMessageNotificationParamTrigger = "trigger"

@objc
public enum MessageNotificationTrigger: Int {
    case push = 0
    case location
    case calendar
    case timeInterval
    case other
}

func triggerToString(_ trigger: MessageNotificationTrigger) -> String {
    return [
        "push", "location", "calendar", "timeInterval", "other"
    ][trigger.rawValue]
}

/// An event that represents the reception of a push notification (or a locally generated one).
@objc(SPMessageNotification)
public class MessageNotification : SelfDescribingAbstract {
    /// The action associated with the notification.
    @objc
    public var action: String?
    /// Attachments added to the notification (they can be part of the data object).
    @objc
    public var attachments: [MessageNotificationAttachment]?
    /// The notification's body.
    @objc
    public var body: String
    /// Variable string values to be used in place of the format specifiers in bodyLocArgs to use to localize the body text to the user's current localization.
    @objc
    public var bodyLocArgs: [String]?
    /// The key to the body string in the app's string resources to use to localize the body text to the user's current localization.
    @objc
    public var bodyLocKey: String?
    /// The category associated to the notification.
    @objc
    public var category: String?
    /// The application is notified of the delivery of the notification if it's in the foreground or background, the app will be woken up (iOS only).
    public var contentAvailable: Bool?
    /// The group which this notification is part of.
    @objc
    public var group: String?
    /// The icon associated to the notification (Android only).
    @objc
    public var icon: String?
    /// The number of items this notification represents. It's the badge number on iOS.
    public var notificationCount: Int?
    /// The time when the event of the notification occurred.
    @objc
    public var notificationTimestamp: String?
    /// The sound played when the device receives the notification.
    @objc
    public var sound: String?
    /// The notification's subtitle. (iOS only)
    @objc
    public var subtitle: String?
    /// An identifier similar to 'group' but usable for different purposes (Android only).
    @objc
    public var tag: String?
    /// An identifier similar to 'group' but usable for different purposes (iOS only).
    @objc
    public var threadIdentifier: String?
    /// The notification's title.
    @objc
    public var title: String
    /// Variable string values to be used in place of the format specifiers in titleLocArgs to use to localize the title text to the user's current localization.
    @objc
    public var titleLocArgs: [String]?
    /// The key to the title string in the app's string resources to use to localize the title text to the user's current localization.
    @objc
    public var titleLocKey: String?
    /// The trigger that raised the notification message.
    @objc
    public var trigger: MessageNotificationTrigger
    
    /// Creates a Message Notification event that represents a push notification or a local notification.
    /// @note The custom data of the push notification have to be tracked separately in custom entities that can be attached to this event.
    /// @param title Title of message notification.
    /// @param body Body content of the message notification.
    /// @param trigger The trigger that raised this notification: remote notification (push), position related (location), date-time related (calendar, timeInterval) or app generated (other).
    @objc
    public init(title: String, body: String, trigger: MessageNotificationTrigger) {
        self.title = title
        self.body = body
        self.trigger = trigger
    }
    
    @objc
    public class func messageNotification(userInfo: [String: NSObject], defaultTitle: String?, defaultBody: String?) -> MessageNotification? {
        guard let aps = userInfo["aps"] as? [String : NSObject] else {
            return nil
        }
        guard let alert = aps["alert"] as? [String : NSObject] else {
            return nil
        }
        // alert fields
        guard let title = alert["title"] as? String ?? defaultTitle,
              let body = alert["body"] as? String ?? defaultBody else {
            return nil
        }
        let event = MessageNotification(title: title, body: body, trigger: .push)
        event.subtitle = alert["subtitle"] as? String
        event.icon = alert["launch-image"] as? String
        event.titleLocKey = alert["title-loc-key"] as? String
        event.titleLocArgs = alert["title-loc-args"] as? [String]
        event.bodyLocKey = alert["loc-key"] as? String
        event.bodyLocArgs = alert["loc-args"] as? [String]
        // aps fields
        event.notificationCount = aps["badge"] as? Int
        event.sound = aps["sound"] as? String
        event.contentAvailable = aps["content-available"] as? Bool
        event.category = aps["category"] as? String
        event.threadIdentifier = aps["thread-id"] as? String
        return event
    }
    
    public override var schema: String {
        return kSPMessageNotificationSchema
    }
    
    public override var payload: [String: NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPMessageNotificationParamAction] = action as NSObject?
        if let attachments = attachments {
            payload[kSPMessageNotificationParamMessageNotificationAttachments] = attachments.map { $0.data } as NSObject
        }
        payload[kSPMessageNotificationParamBody] = body as NSObject?
        if let bodyLocArgs = bodyLocArgs {
            payload[kSPMessageNotificationParamBodyLocArgs] = bodyLocArgs as NSObject
        }
        payload[kSPMessageNotificationParamBodyLocKey] = bodyLocKey as NSObject?
        payload[kSPMessageNotificationParamCategory] = category as NSObject?
        if let contentAvailable = contentAvailable {
            payload[kSPMessageNotificationParamContentAvailable] = NSNumber(value: contentAvailable)
        }
        payload[kSPMessageNotificationParamGroup] = group as NSObject?
        payload[kSPMessageNotificationParamIcon] = icon as NSObject?
        payload[kSPMessageNotificationParamNotificationCount] = notificationCount as NSObject?
        payload[kSPMessageNotificationParamNotificationTimestamp] = notificationTimestamp as NSObject?
        payload[kSPMessageNotificationParamSound] = sound as NSObject?
        payload[kSPMessageNotificationParamSubtitle] = subtitle as NSObject?
        payload[kSPMessageNotificationParamTag] = tag as NSObject?
        payload[kSPMessageNotificationParamThreadIdentifier] = threadIdentifier as NSObject?
        payload[kSPMessageNotificationParamTitle] = title as NSObject?
        if let titleLocArgs = titleLocArgs {
            payload[kSPMessageNotificationParamTitleLocArgs] = titleLocArgs as NSObject
        }
        payload[kSPMessageNotificationParamTitleLocKey] = titleLocKey as NSObject?
        payload[kSPMessageNotificationParamTrigger] = triggerToString(trigger) as NSObject
        return payload
    }
}
