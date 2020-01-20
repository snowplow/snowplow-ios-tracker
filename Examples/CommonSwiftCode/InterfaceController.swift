//
//  InterfaceController.swift
//  SnowplowSwiftDemoWatch WatchKit Extension
//
//  Created by Leo Mehlig on 12.11.19.
//  Copyright © 2019 snowplowanalytics. All rights reserved.
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
