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

@objc
public class SPSize: NSObject, NSCoding {
    @objc
    public private(set) var width = 0
    @objc
    public private(set) var height = 0

    @objc
    public init(width: Int, height: Int) {
        super.init()
        self.width = width
        self.height = height
    }

    public func encode(with coder: NSCoder) {
        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
    }

    required public init?(coder: NSCoder) {
        super.init()
        width = coder.decodeInteger(forKey: "width")
        height = coder.decodeInteger(forKey: "height")
    }
}
