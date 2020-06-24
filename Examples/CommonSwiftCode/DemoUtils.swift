//
//  DemoUtils.swift
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

import Foundation
import SnowplowTracker

class DemoUtils {
    static func trackAll(_ tracker: SPTracker) {
        self.trackPageViewWithTracker(tracker)
        self.trackScreenViewWithTracker(tracker)
        self.trackStructuredEventWithTracker(tracker)
        self.trackUnstructuredEventWithTracker(tracker)
        self.trackTimingWithCategoryWithTracker(tracker)
        self.trackEcommerceTransactionWithTracker(tracker)
        self.trackPushNotificationWithTracker(tracker)
    }
    
    static func trackStructuredEventWithTracker(_ tracker: SPTracker) {
        let event = SPStructured.build({ (builder : SPStructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
        })
        tracker.track(event)
    }
    
    static func trackUnstructuredEventWithTracker(_ tracker: SPTracker) {
        var event = SPStructured.build({ (builder : SPStructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
        })
        tracker.track(event)
        
        event = SPStructured.build({ (builder : SPStructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackPageViewWithTracker(_ tracker: SPTracker) {
        let data: NSDictionary = [ "targetUrl": "http://a-target-url.com"]
        let sdj = SPSelfDescribingJson(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", andData: data)!

        var event = SPUnstructured.build({ (builder : SPUnstructuredBuilder?) -> Void in
            builder!.setEventData(sdj)
        })
        tracker.track(event)
        
        event = SPUnstructured.build({ (builder : SPUnstructuredBuilder?) -> Void in
            builder!.setEventData(sdj)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackScreenViewWithTracker(_ tracker: SPTracker) {
        let screenId = UUID().uuidString
        var event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName("DemoScreenName")
            builder!.setScreenId(screenId)
        })
        tracker.track(event)
        
        event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName("DemoScreenName")
            builder!.setScreenId(screenId)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackTimingWithCategoryWithTracker(_ tracker: SPTracker) {
        var event = SPTiming.build({ (builder : SPTimingBuilder?) -> Void in
            builder!.setCategory("DemoTimingCategory")
            builder!.setVariable("DemoTimingVariable")
            builder!.setTiming(5)
            builder!.setLabel("DemoTimingLabel")
        })
        tracker.track(event)
        
        event = SPTiming.build({ (builder : SPTimingBuilder?) -> Void in
            builder!.setCategory("DemoTimingCategory")
            builder!.setVariable("DemoTimingVariable")
            builder!.setTiming(5)
            builder!.setLabel("DemoTimingLabel")
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackEcommerceTransactionWithTracker(_ tracker: SPTracker) {
        let transactionID = "6a8078be"
        let itemArray : [Any] = [ SPEcommerceItem.build({ (builder : SPEcommTransactionItemBuilder?) -> Void in
            builder!.setItemId(transactionID)
            builder!.setSku("DemoItemSku")
            builder!.setName("DemoItemName")
            builder!.setCategory("DemoItemCategory")
            builder!.setPrice(0.75)
            builder!.setQuantity(1)
            builder!.setCurrency("USD")
        }) ]
        
        var event = SPEcommerce.build({ (builder : SPEcommTransactionBuilder?) -> Void in
            builder!.setOrderId(transactionID)
            builder!.setTotalValue(350)
            builder!.setAffiliation("DemoTransactionAffiliation")
            builder!.setTaxValue(10)
            builder!.setShipping(15)
            builder!.setCity("Boston")
            builder!.setState("Massachusetts")
            builder!.setCountry("USA")
            builder!.setCurrency("USD")
            builder!.setItems(itemArray)
        })
        tracker.track(event)
        
        event = SPEcommerce.build({ (builder : SPEcommTransactionBuilder?) -> Void in
            builder!.setOrderId(transactionID)
            builder!.setTotalValue(350)
            builder!.setAffiliation("DemoTransactionAffiliation")
            builder!.setTaxValue(10)
            builder!.setShipping(15)
            builder!.setCity("Boston")
            builder!.setState("Massachusetts")
            builder!.setCountry("USA")
            builder!.setCurrency("USD")
            builder!.setItems(itemArray)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }

    static func trackPushNotificationWithTracker(_ tracker: SPTracker) {
        let attachments = [["identifier": "testidentifier",
                            "url": "testurl",
                            "type": "testtype"]]

        var userInfo = Dictionary<String, Any>()
        userInfo["test"] = "test"

        let content = SPNotificationContent.build({(builder : SPNotificationContentBuilder?) -> Void in
            builder!.setTitle("title")
            builder!.setSubtitle("subtitle")
            builder!.setBody("body")
            builder!.setBadge(5)
            builder!.setSound("sound")
            builder!.setLaunchImageName("launchImageName")
            builder!.setUserInfo(userInfo)
            builder!.setAttachments(attachments)
        })

        let event = SPPushNotification.build({(builder : SPPushNotificationBuilder?) -> Void in
            builder!.setTrigger("PUSH") // can be "PUSH", "LOCATION", "CALENDAR", or "TIME_INTERVAL"
            builder!.setAction("action")
            builder!.setDeliveryDate("date")
            builder!.setCategoryIdentifier("category")
            builder!.setThreadIdentifier("thread")
            builder!.setNotification(content)
        })

        tracker.track(event)
    }
}
