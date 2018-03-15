//
//  ViewController.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 1/17/18.
//  Copyright © 2018 snowplowanalytics. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import SwiftTryCatch
import SnowplowTracker

class ViewController: UIViewController, UITextFieldDelegate, SPRequestCallback {
    @IBOutlet weak var uriField: UITextField!
    @IBOutlet weak var trackingSwitch: UISegmentedControl!
    @IBOutlet weak var protocolSwitch: UISegmentedControl!
    @IBOutlet weak var methodSwitch: UISegmentedControl!
    @IBOutlet weak var isRunningLabel: UILabel!
    @IBOutlet weak var isBackgroundLabel: UILabel!
    @IBOutlet weak var sessionCountLabel: UILabel!
    @IBOutlet weak var isOnlineLabel: UILabel!
    @IBOutlet weak var madeLabel: UILabel!
    @IBOutlet weak var dbCountLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    
    var tracker : SPTracker!
    var madeCounter : Int = 0
    var sentCounter : Int = 0
    var updateTimer : Timer!
    var uri : String = ""
    var methodType : SPRequestOptions = SPRequestGet
    var protocolType : SPProtocol = SPHttp
    
    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"

    
    func setup() {
        self.tracker = self.getTracker("acme.fake.com", method: SPRequestPost)
        self.updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMetrics), userInfo: nil, repeats: true)
        self.uriField.delegate = self
        self.trackingSwitch.addTarget(self, action: #selector(action), for: .valueChanged)
    }
    
    @objc func action() {
        let tracking: Bool = (trackingSwitch.selectedSegmentIndex == 0)
        if (tracking && !(tracker.getIsTracking())) {
            tracker.resumeEventTracking()
        } else if (tracker.getIsTracking()) {
            tracker.pauseEventTracking()
        }
    }
    
    func getCollectorUrl() -> String {
        return self.uri
    }
    
    func getMethodType() -> SPRequestOptions {
        return self.methodType
    }
    
    func getProtocolType() -> SPProtocol {
        return self.protocolType
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.uri = uriField.text!
        return textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func inputUri(_ sender: UITextField) {
        self.uri = uriField.text!
    }
    
    @IBAction func toggleMethod(_ sender: UISegmentedControl) {
        self.methodType = (methodSwitch.selectedSegmentIndex == 0) ?
            SPRequestGet : SPRequestPost
    }
    
    @IBAction func toggleProtocol(_ sender: UISegmentedControl) {
        self.protocolType = (protocolSwitch.selectedSegmentIndex == 0) ?
            SPHttp : SPHttps
    }
    
    @IBAction func trackEvents(_ sender: UIButton) {
        DispatchQueue.global(qos: .default).async {
            let url = self.getCollectorUrl()
            if url == "" {
                return
            }
            
            // Update the tracker
            
            SwiftTryCatch.try({
                self.tracker.emitter.setUrlEndpoint(url)
            }, catch: { (error) in
                return
            }, finally: {
                
            })
            
            self.tracker.emitter.setHttpMethod(self.getMethodType())
            self.tracker.emitter.setProtocol(self.getProtocolType())
            
            // Iterate the made counter
            self.madeCounter += 28;
            
            // Track all types of events
            DemoUtils.trackAll(self.tracker)
        }
    }
    
    @objc func updateMetrics() {
        madeLabel.text = String(format: "Made: %lld", madeCounter)
        dbCountLabel.text = String(format: "DB Count: %lu", CUnsignedLong(self.tracker.emitter.getDbCount()))
        sessionCountLabel.text = String(format: "Session Count: %lu", CUnsignedLong(self.tracker.getSessionIndex()))
        isRunningLabel.text = String(format: "Running: %@", self.tracker.emitter.getSendingStatus() ? "yes" : "no")
        isBackgroundLabel.text = String(format: "Background: %@", self.tracker.getInBackground() ? "yes" : "no")
        isOnlineLabel.text = String(format: "Online: %@", SPUtilities.isOnline() ? "yes" : "no")
        sentLabel.text = String(format: "Sent: %lu", CUnsignedLong(sentCounter))
    }
    
    // Tracker setup and init
    
    func getTracker(_ url: String, method: SPRequestOptions) -> SPTracker {
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            builder!.setUrlEndpoint(url)
            builder!.setHttpMethod(method)
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
        })
        return newTracker!
    }
    
    // Define Callback Functions
    
    func onSuccess(withCount successCount: Int) {
        self.sentCounter += successCount;
    }
    
    func onFailure(withCount failureCount: Int, successCount: Int) {
        self.sentCounter += successCount;
    }
}
