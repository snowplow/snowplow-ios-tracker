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

let kRulePattern = "^iglu:((?:(?:[a-zA-Z0-9-_]+|\\*)\\.)+(?:[a-zA-Z0-9-_]+|\\*))\\/([a-zA-Z0-9-_\\.]+|\\*)\\/([a-zA-Z0-9-_\\.]+|\\*)\\/([1-9][0-9]*|\\*)-(0|[1-9][0-9]*|\\*)-(0|[1-9][0-9]*|\\*)$"
let kUriPattern = "^iglu:((?:(?:[a-zA-Z0-9-_]+)\\.)+(?:[a-zA-Z0-9-_]+))\\/([a-zA-Z0-9-_]+)\\/([a-zA-Z0-9-_]+)\\/([1-9][0-9]*)\\-(0|[1-9][0-9]*)\\-(0|[1-9][0-9]*)$"

class SchemaRule: Equatable {
    private(set) var rule: String
    private(set) var ruleParts: [String]

    func copy(with zone: NSZone? = nil) -> Any {
        return SchemaRule(rule: rule) as Any
    }

    required init?(rule: String) {
        self.rule = rule
        guard let parts = SchemaRule.parts(fromUri: rule, regexPattern: kRulePattern) else { return nil }
        // reject rule if vendor format isn't valid
        if (parts.count == 0 || !SchemaRule.validateVendor(parts[0])) {
            return nil
        }
        ruleParts = parts
    }

    func match(withUri uri: String) -> Bool {
        guard let uriParts = SchemaRule.parts(fromUri: uri, regexPattern: kUriPattern) else {
            return false
        }
        if uriParts.count < ruleParts.count {
            return false
        }
        // Check vendor part
        let ruleVendor = ruleParts[0].components(separatedBy: ".")
        let uriVendor = uriParts[0].components(separatedBy: ".")
        if uriVendor.count != ruleVendor.count {
            return false
        }
        var index = 0
        for ruleVendorPart in ruleVendor {
            if ("*" != ruleVendorPart) && (uriVendor[index] != ruleVendorPart) {
                return false
            }
            index += 1
        }
        // Check the rest of the rule
        index = 1
        for rulePart in (ruleParts as NSArray).subarray(with: NSRange(location: 1, length: ruleParts.count - 1)) {
            guard let rulePart = rulePart as? String else {
                continue
            }
            if ("*" != rulePart) && (uriParts[index] != rulePart) {
                return false
            }
            index += 1
        }
        return true
    }

    // MARK: - Private methods

    class func parts(fromUri uri: String, regexPattern pattern: String) -> [String]? {
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
        }
        let match = regex?.firstMatch(in: uri, options: [], range: NSRange(location: 0, length: uri.count))
        if match == nil {
            return nil
        }
        var parts: [String] = []
        for i in 1..<(match?.numberOfRanges ?? 0) {
            if i > 6 {
                return nil
            }
            if let range = match?.range(at: i) {
                let part = (uri as NSString).substring(with: range)
                parts.append(part)
            }
        }
        return parts
    }

    class func validateVendor(_ vendor: String) -> Bool {
        // the components array will be generated like this from vendor:
        // "com.acme.marketing" => ["com", "acme", "marketing"]
        let components = vendor.components(separatedBy: ".")
        // check that vendor doesn't begin or end with period
        // e.g. ".snowplowanalytics.snowplow." => ["", "snowplowanalytics", "snowplow", ""]
        if components.count > 1 && (components[0].count == 0 || components[components.count - 1].count == 0) {
            return false
        }
        // reject vendors with criteria that are too broad & don't make sense, i.e. "*.*.marketing"
        if ("*" == components[0]) || ("*" == components[1]) {
            return false
        }
        // now validate the remaining parts, vendors should follow matching that never breaks trailing specificity
        // in other words, once we use an asterisk, we must continue using asterisks for parts or stop
        // e.g. "com.acme.marketing.*.*" is allowed, but "com.acme.*.marketing.*" or "com.acme.*.marketing" is forbidden
        if components.count <= 2 {
            return true
        }
        // trailingComponents are the remaining parts after the first two
        let trailingComponents = (components as NSArray).subarray(with: NSRange(location: 2, length: components.count - 2)) as? [String]
        var asterisk = false
        for part in trailingComponents ?? [] {
            if "*" == part {
                // mark when we've found a wildcard
                asterisk = true
            } else if asterisk {
                // invalid when alpha parts come after wildcard
                return false
            }
        }
        return true
    }
    
    static func == (lhs: SchemaRule, rhs: SchemaRule) -> Bool {
        return lhs.rule == rhs.rule
    }

}
