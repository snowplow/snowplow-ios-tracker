//
//  ConfigurationProvider.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

typealias OnFetchCallback = (FetchedConfigurationBundle, ConfigurationState) -> Void

/// This class fetches a configuration from a remote source otherwise it provides a cached configuration.
/// It can manage multiple sources and multiple caches.
class ConfigurationProvider {
    private var remoteConfiguration: RemoteConfiguration
    private var cache: ConfigurationCache
    private var fetcher: ConfigurationFetcher?
    private var defaultBundle: FetchedConfigurationBundle?
    private var cacheBundle: FetchedConfigurationBundle?

    convenience init(remoteConfiguration: RemoteConfiguration) {
        self.init(remoteConfiguration: remoteConfiguration, defaultConfigurationBundles: nil)
    }

    init(remoteConfiguration: RemoteConfiguration, defaultConfigurationBundles defaultBundles: [ConfigurationBundle]?) {
        self.remoteConfiguration = remoteConfiguration
        cache = ConfigurationCache(remoteConfiguration: remoteConfiguration)
        if let defaultBundles = defaultBundles {
            let bundle = FetchedConfigurationBundle(
                schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0",
                configurationVersion: NSInteger.min)
            bundle.configurationBundle = defaultBundles
            defaultBundle = bundle
        }
    }

    func retrieveConfigurationOnlyRemote(_ onlyRemote: Bool, onFetchCallback: @escaping OnFetchCallback) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if !onlyRemote {
            if cacheBundle == nil {
                cacheBundle = cache.read()
            }
            if let cacheBundle = cacheBundle {
                onFetchCallback(cacheBundle, .cached)
            } else if let defaultBundle = defaultBundle {
                onFetchCallback(defaultBundle, .default)
            }
        }
        fetcher = ConfigurationFetcher(remoteSource: remoteConfiguration) { bundle, state in
            if !self.schemaCompatibility(bundle.schema) {
                return
            }
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            if let cacheBundle = self.cacheBundle {
                if cacheBundle.configurationVersion >= bundle.configurationVersion {
                    return
                }
            }
            self.cache.write(bundle)
            self.cacheBundle = bundle
            onFetchCallback(bundle, ConfigurationState.fetched)
        }
    }

    // Private methods

    private func schemaCompatibility(_ schema: String) -> Bool {
        return schema.hasPrefix("http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-")
    }
}
