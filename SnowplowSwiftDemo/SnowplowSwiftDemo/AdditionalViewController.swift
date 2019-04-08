//
//  AdditionalViewController.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 4/12/19.
//  Copyright © 2019 snowplowanalytics. All rights reserved.
//

import Foundation
import UIKit
import SnowplowTracker

class AdditionalViewController: UIViewController, UITextFieldDelegate, PageObserver {
    
    @IBOutlet weak var trackingSwitch: UISegmentedControl!
    weak var tracker : SPTracker?
    
    @objc dynamic var snowplowId: String! = "additional view"
    
    var parentPageViewController: PageViewController!
    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
        tracker = parentRef.tracker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func crashTheApp () {
        NSException(name:NSExceptionName(rawValue: "name"), reason:"reason", userInfo:nil).raise()
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
