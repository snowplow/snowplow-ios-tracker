//
//  ReachabilityBridge.swift
//  Snowplow
//
//  Created by Michael Hadam on 12/18/18.
//  Copyright © 2018 Snowplow Analytics. All rights reserved.
//

import Foundation
import Reachability

@objc public class ReachabilityBridge: NSObject {

    @objc static public func connectionType() -> String {
        let reachability = Reachability()!
        do {
            try reachability.startNotifier()
        } catch {
            return "error"
        }
        if reachability.connection == .wifi {
            reachability.stopNotifier()
            return "wifi"
        } else {
            reachability.stopNotifier()
            return "cell"
        }
    }

    @objc static public func isOnline() -> Bool {
        let reachability = Reachability()!
        do {
            try reachability.startNotifier()
        } catch {
            return false
        }
        return reachability.connection != .none
    }
}

