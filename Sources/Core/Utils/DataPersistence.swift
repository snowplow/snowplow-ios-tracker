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

var instances: [String : DataPersistence]? = nil
let kSPSessionDictionaryPrefix = "SPSessionDictionary"
let kFilename = "namespace"
let kFilenameExt = "dict"
let kSessionFilenameV1 = "session.dict"
let kSessionFilenamePrefixV2_2 = "session"
var sessionKey = "session"

class DataPersistence {
    var data: [String : [String : Any]] {
        get {
            if !isStoredOnFile {
                return ((UserDefaults.standard.dictionary(forKey: userDefaultsKey) ?? [:]) as? [String : [String : Any]]) ?? [:]
            }
            var result: [String : [String : Any]]? = nil
            if let fileUrl = fileUrl {
                result = NSDictionary(contentsOf: fileUrl) as? [String : [String : Any]]
            }

            if result == nil {
                // Initialise
                result = [:]
                var sessionDict: [String : Any] = [:]
                // Add missing fields
                sessionDict[kSPSessionFirstEventId] = ""
                sessionDict[kSPSessionStorage] = "LOCAL_STORAGE"
                // Wrap up
                result?[sessionKey] = sessionDict
                if let result = result, let fileUrl = fileUrl {
                    let _ = storeDictionary(result, fileURL: fileUrl)
                }
            }

            return result ?? [:]
        }
        set(data) {
            if let fileUrl = fileUrl {
                let _ = storeDictionary(data, fileURL: fileUrl)
            } else {
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            }
        }
    }

    var session: [String : Any]? {
        get {
            return (data)[sessionKey]
        }
        set(session) {
            var data = self.data
            data[sessionKey] = session
            self.data = data
        }
    }

    var isStoredOnFile: Bool {
        return fileUrl != nil
    }
    private var escapedNamespace: String = ""
    private var userDefaultsKey: String = ""
    private var directoryUrl: URL?
    private var fileUrl: URL?

    init(namespace escapedNamespace: String, storedOnFile isStoredOnFile: Bool) {
        self.escapedNamespace = escapedNamespace
        userDefaultsKey = "\(kSPSessionDictionaryPrefix)_\(escapedNamespace)"
#if !(os(tvOS) || os(watchOS))
        if isStoredOnFile {
            let directoryUrl = createDirectoryUrl()
            let filename = "\(kFilename)_\(escapedNamespace).\(kFilenameExt)"
            fileUrl = directoryUrl?.appendingPathComponent(filename)
            self.directoryUrl = directoryUrl
        }
#endif
    }

    class func getFor(namespace: String, storedOnFile isStoredOnFile: Bool = true) -> DataPersistence? {
        let escapedNamespace = DataPersistence.string(fromNamespace: namespace)
        if escapedNamespace.count <= 0 {
            return nil
        }
        
        if let instances = instances {
            if let instance = instances[escapedNamespace] {
                return instance
            }
        } else {
            instances = [:]
        }
        
        let instance = DataPersistence(namespace: escapedNamespace, storedOnFile: isStoredOnFile)
        instances?[escapedNamespace] = instance
        return instance
    }

    class func remove(withNamespace namespace: String) -> Bool {
        if let instance = DataPersistence.getFor(namespace: namespace) {
            instances?.removeValue(forKey: instance.escapedNamespace)
            let _ = instance.removeAll()
        }
        return true
    }

    class func string(fromNamespace namespace: String) -> String {
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: "[^a-zA-Z0-9_]+", options: [])
        } catch {
        }
        return regex?.stringByReplacingMatches(in: namespace, options: [], range: NSRange(location: 0, length: namespace.count), withTemplate: "-") ?? ""
    }

    // MARK: - Private instance methods


    func removeAll() -> Bool {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        if let fileUrl = fileUrl {
            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch let error {
                logError(message: error.localizedDescription)
                return false
            }
        }
        return true
    }

    func createDirectoryUrl() -> URL? {
        let fileManager = FileManager.default
        var url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
        url = url?.appendingPathComponent("snowplow", isDirectory: true)
        
        var error: Error? = nil
        do {
            if try url?.checkResourceIsReachable() ?? false {
                return url
            }
        } catch let e {
            error = e
        }
        
        do {
            if let url = url {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return url
            }
        } catch let e {
            error = e
        }
        
        if let error = error {
            logError(message: String(format: "Unable to create directory for tracker data persistence: %@", error.localizedDescription))
        }
        return nil
    }

    func storeDictionary(_ dictionary: [AnyHashable : Any], fileURL fileUrl: URL) -> Bool {
        if #available(iOS 11.0, macOS 10.13, watchOS 4.0, *) {
            do {
                try (dictionary as NSDictionary).write(to: fileUrl)
                return true
            } catch let error {
                logError(message: String(format: "Unable to write file for sessions: %@", error.localizedDescription))
            }
        } else {
            return (dictionary as NSDictionary).write(to: fileUrl, atomically: true)
        }
        return false
    }
}
