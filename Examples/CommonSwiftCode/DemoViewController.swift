//
//  ViewController.swift
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

import UIKit
import Foundation
import CoreData
import SnowplowTracker

// Used for all child views
protocol PageObserver: class {
    func getParentPageViewController(parentRef: PageViewController)
}

class DemoViewController: UIViewController, UITextFieldDelegate, PageObserver {
    private let keyUriField = "URL-Endpoint";

    @IBOutlet weak var uriField: UITextField!
    @IBOutlet weak var trackingSwitch: UISegmentedControl!
    @IBOutlet weak var protocolSwitch: UISegmentedControl!
    @IBOutlet weak var methodSwitch: UISegmentedControl!
    weak var tracker : SPTracker?

    var parentPageViewController: PageViewController!
    @objc dynamic var snowplowId: String! = "demo view"

    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
        tracker = parentRef.tracker
    }

    @objc func action() {
        let tracking: Bool = (trackingSwitch.selectedSegmentIndex == 0)
        if (tracking && !(tracker?.getIsTracking() ?? false)) {
            tracker?.resumeEventTracking()
        } else if (tracker?.getIsTracking() ?? false) {
            tracker?.pauseEventTracking()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.parentPageViewController.uri = uriField.text!
        return textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uriField.delegate = self
        self.trackingSwitch.addTarget(self, action: #selector(action), for: .valueChanged)
        // Do any additional setup after loading the view, typically from a nib.
        uriField.text = UserDefaults.standard.string(forKey: keyUriField) ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func inputUri(_ sender: UITextField) {
        self.parentPageViewController.uri = uriField.text!
    }
    
    @IBAction func toggleMethod(_ sender: UISegmentedControl) {
        self.parentPageViewController.methodType = (methodSwitch.selectedSegmentIndex == 0) ?
            .get : .post
    }
    
    @IBAction func toggleProtocol(_ sender: UISegmentedControl) {
        self.parentPageViewController.protocolType = (protocolSwitch.selectedSegmentIndex == 0) ?
            .http: .https
    }
    
    @IBAction func trackEvents(_ sender: UIButton) {
        UserDefaults.standard.set(uriField.text ?? "", forKey: keyUriField);
        DispatchQueue.global(qos: .default).async {
            let url = self.parentPageViewController.getCollectorUrl()
            if url == "" {
                return
            }
            
            // Update the tracker
            self.tracker?.emitter.setUrlEndpoint(url)
            self.tracker?.emitter.setHttpMethod(self.parentPageViewController.getMethodType())
            self.tracker?.emitter.setProtocol(self.parentPageViewController.getProtocolType())
            
            // Iterate the made counter
            self.parentPageViewController.madeCounter += 14;
            
            // Track all types of events
            DemoUtils.trackAll(self.parentPageViewController.tracker)
        }
    }
}
