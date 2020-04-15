//
//  InterfaceController.swift
//  SnowplowSwiftDemoWatch WatchKit Extension
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
//  Authors: Leo Mehlig
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

import WatchKit
import Foundation
import SnowplowTracker

class InterfaceController: WKInterfaceController, SPRequestCallback {
    
    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"
    
    func getTracker(_ url: String, method: SPRequestOptions, protocol _protocol: SPProtocol) -> SPTracker {
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            builder!.setUrlEndpoint(url)
            builder!.setHttpMethod(method)
            builder!.setProtocol(_protocol)
            builder!.setCallback(self)
            builder!.setEmitRange(500)
            builder!.setEmitThreadPoolSize(20)
            builder!.setByteLimitPost(52000)
        })
        let subject = SPSubject(platformContext: true, andGeoContext: false)
        let newTracker = SPTracker.build({ (builder : SPTrackerBuilder?) -> Void in
            builder!.setEmitter(emitter)
            builder!.setAppId(self.kAppId)
            builder!.setTrackerNamespace(self.kNamespace)
            builder!.setBase64Encoded(false)
            builder!.setSessionContext(true)
            builder!.setSubject(subject)
            builder!.setLifecycleEvents(true)
            builder!.setAutotrackScreenViews(true)
            builder!.setScreenContext(true)
            builder!.setApplicationContext(true)
            builder!.setExceptionEvents(true)
            builder!.setInstallEvent(true)
            builder!.setGdprContextWith(SPGdprProcessingBasis.consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
        })
        return newTracker!
    }
    
    var tracker : SPTracker!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.tracker = self.getTracker("acme.fake.com", method: .get, protocol: .http)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func sendEvent() {
        DispatchQueue.global(qos: .default).async {
            // Track all types of events
            DemoUtils.trackAll(self.tracker)
        }
    }
    
    func onSuccess(withCount successCount: Int) {
        print("Success: \(successCount)")
    }
    
    func onFailure(withCount failureCount: Int, successCount: Int) {
        print("Failure: \(failureCount), Success: \(successCount)")
    }
    
}
