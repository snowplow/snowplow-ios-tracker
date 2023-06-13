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

typealias OnFetchCallback = (RemoteConfigurationBundle, ConfigurationState) -> Void

/// This class fetches a configuration from a remote source otherwise it provides a cached configuration.
/// It can manage multiple sources and multiple caches.
class RemoteConfigurationProvider {
    private var remoteConfiguration: RemoteConfiguration
    private var cache: RemoteConfigurationCache
    private var fetcher: RemoteConfigurationFetcher?
    private var defaultBundle: RemoteConfigurationBundle?
    private var cacheBundle: RemoteConfigurationBundle?

    convenience init(remoteConfiguration: RemoteConfiguration) {
        self.init(remoteConfiguration: remoteConfiguration, defaultConfigurationBundles: nil)
    }

    init(remoteConfiguration: RemoteConfiguration,
         defaultConfigurationBundles defaultBundles: [ConfigurationBundle]?,
         defaultBundleVersion: Int = NSInteger.min) {
        self.remoteConfiguration = remoteConfiguration
        cache = RemoteConfigurationCache(remoteConfiguration: remoteConfiguration)
        if let defaultBundles = defaultBundles {
            let bundle = RemoteConfigurationBundle(
                schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0",
                configurationVersion: defaultBundleVersion)
            bundle.configurationBundle = defaultBundles
            defaultBundle = bundle
        }
    }

    func retrieveConfigurationOnlyRemote(_ onlyRemote: Bool, onFetchCallback: @escaping OnFetchCallback) {
        if !onlyRemote {
            lock {
                if cacheBundle == nil {
                    cacheBundle = cache.read()
                }
                if let cacheBundle = cacheBundle {
                    if let defaultBundle = defaultBundle {
                        cacheBundle.updateSourceConfig(defaultBundle)
                    }
                    onFetchCallback(cacheBundle, .cached)
                } else if let defaultBundle = defaultBundle {
                    onFetchCallback(defaultBundle, .default)
                }
            }
        }
        fetcher = RemoteConfigurationFetcher(remoteSource: remoteConfiguration) { bundle, state in
            if !self.schemaCompatibility(bundle.schema) {
                return
            }
            let updated: Bool = self.lock {
                if let oldBundle = self.cacheBundle ?? self.defaultBundle {
                    if oldBundle.configurationVersion >= bundle.configurationVersion {
                        return false
                    }
                }
                if let defaultBundle = self.defaultBundle {
                    bundle.updateSourceConfig(defaultBundle)
                }
                self.cache.write(bundle)
                self.cacheBundle = bundle
                return true
            }
            if updated {
                onFetchCallback(bundle, ConfigurationState.fetched)
            }
        }
    }
    
    // Private methods
    
    private func schemaCompatibility(_ schema: String) -> Bool {
        return schema.hasPrefix("http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-")
    }
    
    private func lock<T>(closure: () -> T) -> T {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return closure()
    }
}
