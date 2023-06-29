//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

import Foundation

/**
 Controller for managing Ecommerce entities.
 */
//@objc(SPEcommController)
public protocol EcommerceController {
    
    /// Add an ecommerce Screen/Page entity to all subsequent events.
    /// - Parameter type The type of screen that was visited, e.g. homepage, product details, cart, checkout, etc.
    /// - Parameter language The language that the screen is based in.
    /// - Parameter locale The locale version of the app that is running.
//    @objc
    func setEcommerceScreen(type: String, language: String?, locale: String?)
    
    /// Add an ecommerce User entity to all subsequent events.
    /// - Parameter id The user ID.
    /// - Parameter is_guest Whether or not the user is a guest.
    /// - Parameter email The user's email address.
    func setEcommerceUser(id: String, isGuest: Bool?, email: String?)
    
    /// Stop adding a Screen/Page entity to events.
//    @objc
    func removeEcommerceScreen()
    
    /// Stop adding a User entity to events.
//    @objc
    func removeEcommerceUser()
}
