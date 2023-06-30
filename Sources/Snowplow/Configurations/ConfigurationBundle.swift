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

/// This class represents the default configuration applied in place of the remote configuration.
@objc(SPConfigurationBundle)
public class ConfigurationBundle: SerializableConfiguration {
    @objc
    private(set) public var namespace: String
    @objc
    public var networkConfiguration: NetworkConfiguration?
    @objc
    public var trackerConfiguration: TrackerConfiguration?
    @objc
    public var subjectConfiguration: SubjectConfiguration?
    @objc
    public var sessionConfiguration: SessionConfiguration?
    @objc
    public var emitterConfiguration: EmitterConfiguration?

    @objc
    public var configurations: [ConfigurationProtocol] {
        var array: [ConfigurationProtocol] = []
        if let networkConfiguration = networkConfiguration {
            array.append(networkConfiguration)
        }
        if let trackerConfiguration = trackerConfiguration {
            array.append(trackerConfiguration)
        }
        if let subjectConfiguration = subjectConfiguration {
            array.append(subjectConfiguration)
        }
        if let sessionConfiguration = sessionConfiguration {
            array.append(sessionConfiguration)
        }
        if let emitterConfiguration = emitterConfiguration {
            array.append(emitterConfiguration)
        }
        return array
    }

    @objc
    public convenience init(namespace: String) {
        self.init(namespace: namespace, networkConfiguration: nil)
    }

    @objc
    public init(namespace: String, networkConfiguration: NetworkConfiguration?) {
        self.namespace = namespace
        self.networkConfiguration = networkConfiguration
    }

    @objc
    public init?(dictionary: [String : Any]) {
        if let namespace = dictionary["namespace"] as? String {
            self.namespace = namespace
        } else {
            logDebug(message: "Error assigning: namespace")
            return nil
        }
        if let config = dictionary["networkConfiguration"] as? [String : Any] {
            networkConfiguration = NetworkConfiguration(dictionary: config)
        }
        if let config = dictionary["trackerConfiguration"] as? [String : Any] {
            trackerConfiguration = TrackerConfiguration(dictionary: config)
        }
        if let config = dictionary["subjectConfiguration"] as? [String : Any] {
            subjectConfiguration = SubjectConfiguration(dictionary: config)
        }
        if let config = dictionary["sessionConfiguration"] as? [String : Any] {
            sessionConfiguration = SessionConfiguration(dictionary: config)
        }
        if let config = dictionary["emitterConfiguration"] as? [String : Any] {
            emitterConfiguration = EmitterConfiguration(dictionary: config)
        }
    }
    
    func updateSourceConfig(_ sourceBundle: ConfigurationBundle) {
        if let sourceNetworkConfig = sourceBundle.networkConfiguration {
            if networkConfiguration == nil { networkConfiguration = NetworkConfiguration() }
            networkConfiguration?.sourceConfig = sourceNetworkConfig
        }
        if let sourceTrackerConfig = sourceBundle.trackerConfiguration {
            if trackerConfiguration == nil { trackerConfiguration = TrackerConfiguration() }
            trackerConfiguration?.sourceConfig = sourceTrackerConfig
        }
        if let sourceSubjectConfig = sourceBundle.subjectConfiguration {
            if subjectConfiguration == nil { subjectConfiguration = SubjectConfiguration() }
            subjectConfiguration?.sourceConfig = sourceSubjectConfig
        }
        if let sourceSessionConfig = sourceBundle.sessionConfiguration {
            if sessionConfiguration == nil { sessionConfiguration = SessionConfiguration() }
            sessionConfiguration?.sourceConfig = sourceSessionConfig
        }
        if let sourceEmitterConfig = sourceBundle.emitterConfiguration {
            if emitterConfiguration == nil { emitterConfiguration = EmitterConfiguration() }
            emitterConfiguration?.sourceConfig = sourceEmitterConfig
        }
    }
    
    // MARK: - NSCopying

    @objc
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = ConfigurationBundle(namespace: namespace)
        copy.networkConfiguration = networkConfiguration?.copy(with: zone) as? NetworkConfiguration
        copy.trackerConfiguration = trackerConfiguration?.copy(with: zone) as? TrackerConfiguration
        copy.subjectConfiguration = subjectConfiguration?.copy(with: zone) as? SubjectConfiguration
        copy.sessionConfiguration = sessionConfiguration?.copy(with: zone) as? SessionConfiguration
        copy.emitterConfiguration = emitterConfiguration?.copy(with: zone) as? EmitterConfiguration
        return copy
    }

    // MARK: - NSSecureCoding
    
    @objc
    public override class var supportsSecureCoding: Bool { return true }

    @objc
    override public func encode(with coder: NSCoder) {
        coder.encode(namespace, forKey: "namespace")
        coder.encode(networkConfiguration, forKey: "networkConfiguration")
        coder.encode(trackerConfiguration, forKey: "trackerConfiguration")
        coder.encode(subjectConfiguration, forKey: "subjectConfiguration")
        coder.encode(sessionConfiguration, forKey: "sessionConfiguration")
        coder.encode(emitterConfiguration, forKey: "emitterConfiguration")
    }

    required init?(coder: NSCoder) {
        if let namespace = coder.decodeObject(forKey: "namespace") as? String {
            self.namespace = namespace
        } else {
            return nil
        }
        networkConfiguration = coder.decodeObject(forKey: "networkConfiguration") as? NetworkConfiguration
        trackerConfiguration = coder.decodeObject(forKey: "trackerConfiguration") as? TrackerConfiguration
        subjectConfiguration = coder.decodeObject(forKey: "subjectConfiguration") as? SubjectConfiguration
        sessionConfiguration = coder.decodeObject(forKey: "sessionConfiguration") as? SessionConfiguration
        emitterConfiguration = coder.decodeObject(forKey: "emitterConfiguration") as? EmitterConfiguration
    }
}
