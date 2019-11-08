//
//  DemoUtils.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 1/19/18.
//  Copyright © 2018 snowplowanalytics. All rights reserved.
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
        tracker.trackStructuredEvent(event)
    }
    
    static func trackUnstructuredEventWithTracker(_ tracker: SPTracker) {
        var event = SPStructured.build({ (builder : SPStructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
        })
        tracker.trackStructuredEvent(event)
        
        event = SPStructured.build({ (builder : SPStructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
            builder!.setTimestamp(1243567890)
        })
        tracker.trackStructuredEvent(event)
    }
    
    static func trackPageViewWithTracker(_ tracker: SPTracker) {
        let data: NSDictionary = [ "targetUrl": "http://a-target-url.com"]
        let sdj = SPSelfDescribingJson(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", andData: data);

        var event = SPUnstructured.build({ (builder : SPUnstructuredBuilder?) -> Void in
            builder!.setEventData(sdj!)
        })
        tracker.trackUnstructuredEvent(event)
        
        event = SPUnstructured.build({ (builder : SPUnstructuredBuilder?) -> Void in
            builder!.setEventData(sdj)
            builder!.setTimestamp(1243567890)
        })
        tracker.trackUnstructuredEvent(event)
    }
    
    static func trackScreenViewWithTracker(_ tracker: SPTracker) {
        let screenId = UUID().uuidString
        var event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName("DemoScreenName")
            builder!.setScreenId(screenId)
        })
        tracker.trackScreenViewEvent(event)
        
        event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName("DemoScreenName")
            builder!.setScreenId(screenId)
            builder!.setTimestamp(1243567890)
        })
        tracker.trackScreenViewEvent(event)
    }
    
    static func trackTimingWithCategoryWithTracker(_ tracker: SPTracker) {
        var event = SPTiming.build({ (builder : SPTimingBuilder?) -> Void in
            builder!.setCategory("DemoTimingCategory")
            builder!.setVariable("DemoTimingVariable")
            builder!.setTiming(5)
            builder!.setLabel("DemoTimingLabel")
        })
        tracker.trackTimingEvent(event)
        
        event = SPTiming.build({ (builder : SPTimingBuilder?) -> Void in
            builder!.setCategory("DemoTimingCategory")
            builder!.setVariable("DemoTimingVariable")
            builder!.setTiming(5)
            builder!.setLabel("DemoTimingLabel")
            builder!.setTimestamp(1243567890)
        })
        tracker.trackTimingEvent(event)
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
        })! ]
        
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
        tracker.trackEcommerceEvent(event)
        
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
        tracker.trackEcommerceEvent(event)
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

        tracker.trackPushNotificationEvent(event)
    }
}
