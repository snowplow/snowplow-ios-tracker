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

/// Common parent class for configuration classes.
@objc(SPSerializableConfiguration)
public class SerializableConfiguration: NSObject, NSCopying, NSSecureCoding {
    @objc
    public convenience init?(dictionary: [String : Any]) {
        self.init()
    }

    @objc
    public func copy(with zone: NSZone? = nil) -> Any {
        return SerializableConfiguration()
    }

    @objc
    public func encode(with coder: NSCoder) {
    }

    @objc
    public class var supportsSecureCoding: Bool { return true }
    
    @objc
    required convenience public init?(coder: NSCoder) {
        self.init()
    }
}
