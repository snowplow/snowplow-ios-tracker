// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

import Foundation

let kSPMessageNotificationAttachmentParamIdentifier = "identifier"
let kSPMessageNotificationAttachmentParamType = "type"
let kSPMessageNotificationAttachmentParamUrl = "url"

/// Attachment object that identify an attachment in the MessageNotification
@objc(SPMessageNotificationAttachment)
public class MessageNotificationAttachment : NSObject {
    @objc
    public var identifer: String
    @objc
    public var type: String
    @objc
    public var url: String
    
    /// Attachments added to the notification (they can be part of the data object).
    @objc
    public init(identifier: String, type: String, url: String) {
        self.identifer = identifier
        self.type = type
        self.url = url
    }
    
    var data: [String : Any] {
        return [
            kSPMessageNotificationAttachmentParamIdentifier: identifer,
            kSPMessageNotificationAttachmentParamType: type,
            kSPMessageNotificationAttachmentParamUrl: url
        ]
    }
}
