//
//  SecondViewController.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 3/3/19.
//  Copyright © 2019 snowplowanalytics. All rights reserved.
//

import UIKit
import SnowplowTracker

class MetricsViewController: UIViewController, UITextFieldDelegate, PageObserver {

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
    @IBOutlet weak var tokenLabel: UILabel!
    var updateTimer : Timer?
    weak var tracker : SPTracker?

    @objc dynamic var snowplowId: String! = "metrics view"

    func updateToken(_ token: String) {
        tokenLabel.text = String(format: "Token: %@", token)
    }

    var parentPageViewController: PageViewController!
    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
        tracker = parentRef.tracker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMetrics), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    @objc func updateMetrics() {
        madeLabel.text = String(format: "Made: %lld", parentPageViewController.madeCounter)
        dbCountLabel.text = String(format: "DB Count: %lu", CUnsignedLong(self.tracker?.emitter.getDbCount() ?? 0))
        sessionCountLabel.text = String(format: "Session Count: %lu", CUnsignedLong(self.tracker?.getSessionIndex() ?? 0))
        isRunningLabel.text = String(format: "Running: %@", self.tracker?.emitter.getSendingStatus() ?? false ? "yes" : "no")
        isBackgroundLabel.text = String(format: "Background: %@", self.tracker?.getInBackground() ?? false ? "yes" : "no")
        isOnlineLabel.text = String(format: "Online: %@", SPUtilities.isOnline() ? "yes" : "no")
        sentLabel.text = String(format: "Sent: %lu", CUnsignedLong(parentPageViewController.sentCounter))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
