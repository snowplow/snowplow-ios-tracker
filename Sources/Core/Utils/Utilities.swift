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

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#endif

/// This is a class that contains utility functions used throughout the tracker.
class Utilities {
    /// Returns the system timezone region.
    /// - Returns: A string of the timezone region (e.g. 'Toronto/Canada').
    class var timezone: String? {
        return TimeZone.current.identifier
    }

    /// Returns the system language currently used on the device.
    /// - Returns: A string of the current language.
    class var language: String? {
        return Locale.preferredLanguages.first
    }

    /// Returns the platform type of the device..
    /// - Returns: A string of the platform type.
    class var platform: DevicePlatform {
        #if os(iOS)
        return .mobile
        #elseif os(visionOS)
        return .headset
        #else
        return .desktop
        #endif
    }

    /// Returns a randomly generated UUID (type 4).
    /// - Returns: A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
    class func getUUIDString() -> String {
        // Generates type 4 UUID
        return UUID().uuidString.lowercased()
    }

    /// Check if the value is a valid UUID (type 4).
    /// - Parameter uuidString: UUID string to validate.
    /// - Returns: Weither is a valid UUID string.
    class func isUUIDString(_ uuidString: String) -> Bool {
        return UUID(uuidString: uuidString) != nil
    }

    /// Returns the timestamp (in milliseconds) generated at the point it was called.
    /// - Returns: A double of the timestamp from when the method was called.
    class func getTimestamp() -> NSNumber {
        let time = Date()
        return NSNumber(value: time.timeIntervalSince1970 * 1000)
    }

    class func timestamp(toISOString timestamp: Int64) -> String? {
        let eventDate = Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
        return dateToISOString(eventDate)
    }

    class func dateToISOString(_ eventDate: Date) -> String? {
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        return formatter.string(from: eventDate)
    }

    /// Calculates the resolution of the screen in-terms of actual pixels of the device. This doesn't count Retine-pixels which are technically subpixels.
    /// - Returns: A formatted string with resolution 'width' and 'height'.
    class var resolution: SPSize? {
        var mainScreen: CGRect?
        var screenScale: CGFloat?
        #if os(iOS) || os(tvOS)
        mainScreen = UIScreen.main.bounds
        screenScale = UIScreen.main.scale
        #elseif os(watchOS)
        mainScreen = WKInterfaceDevice.current().screenBounds
        screenScale = WKInterfaceDevice.current().screenScale
        #elseif os(macOS)
        mainScreen = NSScreen.main?.frame
        screenScale = NSScreen.main?.backingScaleFactor ?? 0.0
        #endif
        if let mainScreen = mainScreen, let screenScale = screenScale {
            let screenWidth = mainScreen.size.width * screenScale
            let screenHeight = mainScreen.size.height * screenScale
            return SPSize(width: Int(screenWidth), height: Int(screenHeight))
        }
        return nil
    }

    /// Calculates the viewport of the app as it is on the screen. Currently, returns the same value as getResolution.
    /// - Returns: A formatted string with viewport width and height.
    class var viewPort: SPSize? {
        // This probably doesn't change as well
        return self.resolution
    }

    /// Returns the Application ID
    /// - Returns: The device bundle application id
    class var appId: String? {
        return Bundle.main.bundleIdentifier
    }
    
    /// URL encodes a dictionary as key=value pairs separated by &, so that it can be used in a query-string.
    ///
    /// This method can encode string, numbers, and bool values, but not embedded arrays or dictionaries.
    /// It encodes bool as 1 and 0.
    /// - Returns: The url encoded string of the dictionary.
    class func urlEncode(_ dictionary: [String : Any]) -> String {
        return dictionary.map { (key: String, value: Any) in
            "\(self.urlEncode(key))=\(self.urlEncode(String(describing: value)))"
        }.joined(separator: "&")
    }

    /// URL encodes a string so that it is suitable to use in a query-string. A nil s returns @"".
    /// - Returns: The url encoded string
    class func urlEncode(_ string: String) -> String {
        var allowedCharSet = CharacterSet.urlQueryAllowed
        allowedCharSet.remove(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharSet) ?? string
    }

    /// Removes all entries which have a value of NSNull from the dictionary.
    /// - Parameter dict: An NSDictionary to be cleaned.
    /// - Returns: The same NSDictionary without any Null values.
    class func removeNullValuesFromDict(withDict dict: [AnyHashable : Any]) -> [AnyHashable : Any] {
        var cleanDictionary: [AnyHashable : Any] = [:]
        for key in dict.keys {
            guard let key = key as? String else {
                continue
            }
            if let aDict = dict[key] {
                if aDict is NSNull { continue }
                cleanDictionary[key] = aDict
            }
        }
        return cleanDictionary
    }

    /// Converts a kebab-case string keys into a camel-case string keys.
    /// - Parameter dict: The dictionary to convert.
    /// - Returns: A dictionary.
    class func replaceHyphenatedKeys(withCamelcase dict: [String : Any]) -> [String : Any] {
        var newDictionary: [String : Any] = [:]
        for key in dict.keys {
            if self.string(key, contains: "-") {
                if let aDict = dict[key] as? [String : Any] {
                    let replaceHyphenatedKeys = self.replaceHyphenatedKeys(withCamelcase: aDict)
                    newDictionary[self.camelcaseParsedKey(key) ?? ""] = replaceHyphenatedKeys
                } else {
                    if let aDict = dict[key] {
                        newDictionary[self.camelcaseParsedKey(key) ?? ""] = aDict
                    }
                }
            } else {
                if let aDict = dict[key] as? [String : Any] {
                    let replaceHyphenatedKeys = self.replaceHyphenatedKeys(withCamelcase: aDict)
                    newDictionary[key] = replaceHyphenatedKeys
                } else {
                    if let aDict = dict[key] {
                        newDictionary[key] = aDict
                    }
                }
            }
        }

        return newDictionary
    }

    class func string(_ string: String, contains subString: String) -> Bool {
        return string.contains(subString)
    }

    /// Converts a kebab-case string into a camel-case string.
    /// - Parameter key: A kebab-case key.
    /// - Returns: A camel-case string.
    class func camelcaseParsedKey(_ key: String) -> String? {
        let words = key.split(separator: "-")

        if words.count == 0 {
            return nil
        } else if words.count == 1 {
            return words[0].lowercased()
        } else {
            var camelcaseKey = words[0].lowercased()
            for word in words[1..<words.count] {
                camelcaseKey += word.capitalized
            }
            return camelcaseKey
        }
    }

    /// Return nil if value is empty string, otherwise return string.
    /// - Parameter aString: Some string
    /// - Returns: A string or nil
    class func validate(_ aString: String) -> String? {
        if aString.count == 0 {
            return nil
        }
        return aString
    }

    /// Returns the application build and version as a payload to be used in the application context.
    /// - Returns: A context SDJ.
    class var applicationContext: SelfDescribingJson? {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            return self.getApplicationContext(withVersion: version, andBuild: build)
        }
        return nil
    }

    /// Returns the application build and version as a payload to be used in the application context.
    /// - Parameters:
    ///   - version: The application version
    ///   - build: The application build
    /// - Returns: A context SDJ.
    class func getApplicationContext(withVersion version: String, andBuild build: String) -> SelfDescribingJson {
        let payload = Payload()
        payload.addValueToPayload(build, forKey: kSPApplicationBuild)
        payload.addValueToPayload(version, forKey: kSPApplicationVersion)
        return SelfDescribingJson(schema: kSPApplicationContextSchema, andPayload: payload)
    }

    /// Returns the app version.
    /// - Returns: App version string.
    class var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the app build.
    /// - Returns: App build string.
    class var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    /// Truncates the scheme of a URL to 16 characters to satisfy the validation for the page_url and page_refr properties.
    class func truncateUrlScheme(_ url: String) -> String {
        let parts = url.components(separatedBy: "://")
        if parts.count > 1 {
            if let scheme = parts.first?.prefix(16) {
                let updatedParts = [String(scheme)] + Array(parts.dropFirst())
                return updatedParts.joined(separator: "://")
            }
        }
        return url
    }
}

