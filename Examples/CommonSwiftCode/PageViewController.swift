//
//  PageViewController.swift
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
import SnowplowTracker

class PageViewController:  UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, SPRequestCallback {

    var tracker : SPTracker!
    var madeCounter : Int = 0
    var sentCounter : Int = 0
    var uri : String = ""
    var methodType : SPRequestOptions = .get
    var protocolType : SPProtocol = .http
    var token : String = ""
    @objc dynamic var snowplowId: String! = "page view"

    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"

    // Tracker setup and init

    func getTracker(_ url: String, method: SPRequestOptions) -> SPTracker {
        let eventStore = SPSQLiteEventStore();
        let network = SPDefaultNetworkConnection.build { (builder) in
            builder.setUrlEndpoint(url)
            builder.setHttpMethod(method)
            builder.setEmitThreadPoolSize(20)
            builder.setByteLimitPost(52000)
        }
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            builder!.setCallback(self)
            builder!.setEmitRange(500)
            builder!.setEventStore(eventStore)
            builder!.setNetworkConnection(network)
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
            // set global context generators
            builder!.setGlobalContextGenerators([
                "ruleSetExampleTag": self.ruleSetGlobalContextExample(),
                "staticExampleTag": self.staticGlobalContextExample(),
            ])
            builder!.setGdprContextWith(SPGdprProcessingBasis.consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
            // set diagnostic and logger delegate
            builder?.setTrackerDiagnostic(true)
            builder?.setLogLevel(.verbose)
            builder?.setLoggerDelegate(self)
        })
        return newTracker!
    }
    
    func ruleSetGlobalContextExample() -> SPGlobalContext {
        let schemaRuleset = SPSchemaRuleset(allowedList: ["iglu:com.snowplowanalytics.*/*/jsonschema/1-*-*"],
                                            andDeniedList: ["iglu:com.snowplowanalytics.mobile/*/jsonschema/1-*-*"])
        return SPGlobalContext(generator: { event -> [SPSelfDescribingJson]? in
            return [
                SPSelfDescribingJson.init(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0", andData: ["key": "rulesetExample"] as NSObject),
                SPSelfDescribingJson.init(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0", andData: ["eventName": event.schema] as NSObject)
            ]
        }, ruleset: schemaRuleset)
    }
    
    func staticGlobalContextExample() -> SPGlobalContext {
        return SPGlobalContext(staticContexts: [
            SPSelfDescribingJson.init(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0", andData: ["key": "staticExample"] as NSObject),
        ])
    }

    func updateToken(_ newToken: String) {
        token = newToken
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
    
    func setup() {
        self.tracker = self.getTracker("acme.fake.com", method: .post)
    }

    func newVc(viewController: String) -> UIViewController {
        let newViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        (newViewController as? PageObserver)?.getParentPageViewController(parentRef: self)
        return newViewController
    }

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "demo"),
                self.newVc(viewController: "metrics"),
                self.newVc(viewController: "additional")]
    }()

    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.setup()
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    func onSuccess(withCount successCount: Int) {
        self.sentCounter += successCount;
    }

    func onFailure(withCount failureCount: Int, successCount: Int) {
        self.sentCounter += successCount;
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

extension PageViewController: SPLoggerDelegate {
    func error(_ tag: String!, message: String!) {
        print("[Error] \(tag!): \(message!)")
    }
    
    func debug(_ tag: String!, message: String!) {
        print("[Debug] \(tag!): \(message!)")
    }
    
    func verbose(_ tag: String!, message: String!) {
        print("[Verbose] \(tag!): \(message!)")
    }
}
