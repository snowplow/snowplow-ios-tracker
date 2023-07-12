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
#if os(iOS) || os(macOS)
import WebKit
#endif

/// Entry point to instance a new Snowplow tracker.
///
/// The following example initializes a tracker instance using the ``createTracker(namespace:endpoint:method:)`` method and tracks a ``SelfDescribing`` event:
///
/// ```swift
/// let tracker = Snowplow.createTracker(
///     namespace: "ns1",
///     endpoint: "https://collector.example.com"
/// )
/// let event = SelfDescribing(
///     schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1",
///     payload: ["targetUrl": "http://a-target-url.com"]
/// )
/// tracker?.track(event)
/// ```
@objc(SPSnowplow)
public class Snowplow: NSObject {
    private static var serviceProviderInstances: [String : ServiceProvider] = [:]
    private static var configurationProvider: RemoteConfigurationProvider?
    private static var defaultServiceProvider: ServiceProvider?
    
    /// Remote Configuration

    /// Setup a single or a set of tracker instances which will be used inside the app to track events.
    ///
    /// The app can run multiple tracker instances which will be identified by string `namespaces`.
    /// The trackers configuration is automatically download from the endpoint indicated in the `RemoteConfiguration`
    /// passed as argument. For more details see `RemoteConfiguration`.
    ///
    /// The method is asynchronous and you can receive the list of the created trackers in the callbacks once the trackers are created.
    /// The callback can be called multiple times in case a cached configuration is ready and later a fetched configuration is available.
    /// You can also pass as argument a default configuration in case there isn't a cached configuration and it's not able to download
    /// a new one. The downloaded configuration updates the cached one only if the configuration version is greater than the cached one.
    /// Otherwise the cached one is kept and the callback is not called.
    ///
    /// IMPORTANT: The EventStore will persist all the events that have been tracked but not yet sent.
    /// Those events are attached to the namespace.
    /// If the tracker is removed or the app relaunched with a different namespace, those events can't
    /// be sent to the collector and they remain in a zombie state inside the EventStore.
    /// To remove all the zombie events you can call an internal method `removeUnsentEventsExceptForNamespaces` on `SPSQLEventStore`
    /// which will delete all the EventStores instanced with namespaces not listed in the passed list.
    ///
    /// - Parameters:
    ///   - remoteConfiguration: The remote configuration used to indicate where to download the configuration from.
    ///   - defaultBundles: The default configuration passed by default in case there isn't a cached version and it's able to download a new one.
    ///   - defaultBundleVersion: Version of the default configuration that will be used to compare with the fetched remote config to decide whether to replace it.
    ///   - onSuccess: The callback called when a configuration (cached or downloaded) is set.
    ///                  It passes two arguments: list of the namespaces associated to the created trackers
    ///                  and the state of the configuration – whether it was retrieved from cache or fetched over the network.
    @objc
    public class func setup(remoteConfiguration: RemoteConfiguration,
                            defaultConfiguration defaultBundles: [ConfigurationBundle]?,
                            defaultConfigurationVersion defaultBundleVersion: Int = NSInteger.min,
                            onSuccess: @escaping (_ namespaces: [String]?, _ configurationState: ConfigurationState) -> Void) {
        configurationProvider = RemoteConfigurationProvider(remoteConfiguration: remoteConfiguration,
                                                            defaultConfigurationBundles: defaultBundles,
                                                            defaultBundleVersion: defaultBundleVersion)
        
        configurationProvider?.retrieveConfigurationOnlyRemote(false, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            let bundles = fetchedConfigurationBundle.configurationBundle
            let namespaces = createTrackers(configurationBundles: bundles)
            onSuccess(namespaces, configurationState)
        })
    }

    /// Reconfigure, create or delete the trackers based on the configuration downloaded remotely.
    ///
    /// The trackers configuration is automatically download from the endpoint indicated in the `RemoteConfiguration`
    /// previously used to setup the trackers.
    ///
    /// The method is asynchronous and you can receive the list of the created trackers in the callbacks once the trackers are created.
    /// The downloaded configuration updates the cached one only if the configuration version is greater than the cached one.
    /// Otherwise the cached one is kept and the callback is not called.
    ///
    /// IMPORTANT: The EventStore will persist all the events that have been tracked but not yet sent.
    /// Those events are attached to the namespace.
    /// If the tracker is removed or the app relaunched with a different namespace, those events can't
    /// be sent to the collector and they remain in a zombie state inside the EventStore.
    /// To remove all the zombie events you can call an internal method `removeUnsentEventsExceptForNamespaces` on `SPSQLEventStore`
    /// which will delete all the EventStores instanced with namespaces not listed in the passed list.
    ///
    /// - Parameter onSuccess: The callback called when a configuration (cached or downloaded) is set It passes the list of the namespaces associated
    ///                  to the created trackers.
    @objc
    public class func refresh(onSuccess: @escaping (_ namespaces: [String]?, _ configurationState: ConfigurationState) -> Void) {
        configurationProvider?.retrieveConfigurationOnlyRemote(true, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            let bundles = fetchedConfigurationBundle.configurationBundle
            let namespaces = createTrackers(configurationBundles: bundles)
            onSuccess(namespaces, configurationState)
        })
    }

    /// Standard Configuration

    /// Create a new tracker instance which will be used inside the app to track events.
    ///
    /// The app can run multiple tracker instances which will be identified by string `namespaces`.
    /// The tracker will be configured with default setting and only the collector endpoint URL need
    /// to be passed for the configuration.
    /// For the default configuration of the tracker see `TrackerConfiguration(String)`.
    ///
    /// To configure tracker with more details see `createTracker(Context, String, NetworkConfiguration, Configuration...)`
    /// To use the tracker as singleton see `getDefaultTracker()`
    ///
    /// IMPORTANT: The EventStore will persist all the events that have been tracked but not yet sent.
    /// Those events are attached to the namespace.
    /// If the tracker is removed or the app relaunched with a different namespace, those events can't
    /// be sent to the collector and they remain in a zombie state inside the EventStore.
    /// To remove all the zombie events you can call an internal method `removeUnsentEventsExceptForNamespaces` on `SPSQLEventStore`
    /// which will delete all the EventStores instanced with namespaces not listed in the passed list.
    ///
    /// - Parameters:
    ///   - namespace: The namespace used to identify the current tracker among the possible
    ///                  multiple tracker instances.
    ///   - endpoint: The URL of the collector.
    ///   - method: The method for the requests to the collector (GET or POST).
    /// - Returns: The tracker instance created.
    @objc
    public class func createTracker(namespace: String, endpoint: String, method: HttpMethodOptions = .post) -> TrackerController? {
        let networkConfiguration = NetworkConfiguration(endpoint: endpoint, method: method)
        return createTracker(namespace: namespace, network: networkConfiguration, configurations: [])
    }

#if swift(>=5.4)
    /// Create a new tracker instance which will be used inside the app to track events.
    ///
    /// The app can run multiple tracker instances which will be identified by string `namespaces`.
    /// The tracker will be configured with default setting and only the collector endpoint URL need
    /// to be passed for the configuration.
    /// For the default configuration of the tracker see `TrackerConfiguration(String)`.
    ///
    /// To configure tracker with more details see `createTracker(Context, String, NetworkConfiguration, Configuration...)`
    /// To use the tracker as singleton see `getDefaultTracker()`
    ///
    /// IMPORTANT: The EventStore will persist all the events that have been tracked but not yet sent.
    /// Those events are attached to the namespace.
    /// If the tracker is removed or the app relaunched with a different namespace, those events can't
    /// be sent to the collector and they remain in a zombie state inside the EventStore.
    /// To remove all the zombie events you can call an internal method `removeUnsentEventsExceptForNamespaces` on `SPSQLEventStore`
    /// which will delete all the EventStores instanced with namespaces not listed in the passed list.
    ///
    /// - Parameters:
    ///   - namespace: The namespace used to identify the current tracker among the possible
    ///                  multiple tracker instances.
    ///   - endpoint: The URL of the collector.
    ///   - method: The method for the requests to the collector (GET or POST).
    ///   - configurationBuilder: Swift DSL builder for your configuration objects (e.g, `EmitterConfiguration`, `TrackerConfiguration`)
    /// - Returns: The tracker instance created.
    public class func createTracker(namespace: String, endpoint: String, method: HttpMethodOptions = .post, @ConfigurationBuilder _ configurationBuilder: () -> [ConfigurationProtocol]) -> TrackerController? {
        let configurations = configurationBuilder()
        return createTracker(namespace: namespace,
                             network: NetworkConfiguration(endpoint: endpoint, method: method),
                             configurations: configurations)
    }
#endif

    /// Create a new tracker instance which will be used inside the app to track events.
    ///
    /// The app can run multiple tracker instances which will be identified by string `namespaces`.
    /// The tracker will be configured with default setting and only the collector endpoint URL need
    /// to be passed for the configuration.
    /// For the default configuration of the tracker see `TrackerConfiguration(String)`.
    ///
    /// To configure tracker with more details see `createTracker(Context, String, NetworkConfiguration, Configuration...)`
    /// To use the tracker as singleton see `getDefaultTracker()`
    ///
    /// IMPORTANT: The EventStore will persist all the events that have been tracked but not yet sent.
    /// Those events are attached to the namespace.
    /// If the tracker is removed or the app relaunched with a different namespace, those events can't
    /// be sent to the collector and they remain in a zombie state inside the EventStore.
    /// To remove all the zombie events you can call an internal method `removeUnsentEventsExceptForNamespaces` on `SPSQLEventStore`
    /// which will delete all the EventStores instanced with namespaces not listed in the passed list.
    ///
    /// - Parameters:
    ///   - namespace: The namespace used to identify the current tracker among the possible
    ///                  multiple tracker instances.
    ///   - networkConfiguration: The NetworkConfiguration object with settings for the communication with the
    ///                collector.
    ///   - configurations: All the configuration objects with the details about the fine tuning of
    ///                       the tracker.
    /// - Returns: The tracker instance created.
    @objc
    public class func createTracker(namespace: String, network networkConfiguration: NetworkConfiguration, configurations: [ConfigurationProtocol] = []) -> TrackerController? {
        if let serviceProvider = serviceProviderInstances[namespace] {
            serviceProvider.reset(configurations: configurations + [networkConfiguration])
            return serviceProvider.trackerController
        } else {
            let serviceProvider = ServiceProvider(namespace: namespace, network: networkConfiguration, configurations: configurations)
            let _ = registerInstance(serviceProvider)
            return serviceProvider.trackerController
        }
    }

#if swift(>=5.4)
    /// Create a new tracker instance which will be used inside the app to track events.
    ///
    /// The app can run multiple tracker instances which will be identified by string `namespaces`.
    /// The tracker will be configured with default setting and only the collector endpoint URL need
    /// to be passed for the configuration.
    /// For the default configuration of the tracker see `TrackerConfiguration(String)`.
    ///
    /// To configure tracker with more details see `createTracker(Context, String, NetworkConfiguration, Configuration...)`
    /// To use the tracker as singleton see `getDefaultTracker()`
    ///
    /// IMPORTANT: The EventStore will persist all the events that have been tracked but not yet sent.
    /// Those events are attached to the namespace.
    /// If the tracker is removed or the app relaunched with a different namespace, those events can't
    /// be sent to the collector and they remain in a zombie state inside the EventStore.
    /// To remove all the zombie events you can call an internal method `removeUnsentEventsExceptForNamespaces` on `SPSQLEventStore`
    /// which will delete all the EventStores instanced with namespaces not listed in the passed list.
    ///
    /// - Parameters:
    ///   - namespace: The namespace used to identify the current tracker among the possible
    ///                  multiple tracker instances.
    ///   - networkConfiguration: The NetworkConfiguration object with settings for the communication with the
    ///                collector.
    ///   - configurationBuilder: Swift DSL builder for your configuration objects (e.g, `EmitterConfiguration`, `TrackerConfiguration`)
    /// - Returns: The tracker instance created.
    public class func createTracker(namespace: String, network networkConfiguration: NetworkConfiguration, @ConfigurationBuilder _ configurationBuilder: () -> [ConfigurationProtocol]) -> TrackerController? {
        let configurations = configurationBuilder()
        return createTracker(namespace: namespace,
                             network: networkConfiguration,
                             configurations: configurations)
    }
#endif
    
    /// Get the default tracker instance.
    ///
    /// The default tracker instance is the first created in the app, but that can be overridden programmatically
    /// calling `setTrackerAsDefault(TrackerController)`.
    @objc
    public class func defaultTracker() -> TrackerController? {
        return defaultServiceProvider?.trackerController
    }

    /// Using the namespace identifier is possible to get the trackerController if already instanced.
    ///
    /// - Parameter namespace: The namespace that identifies the tracker.
    /// - Returns: The tracker if it exist with that namespace.
    @objc
    public class func tracker(namespace: String) -> TrackerController? {
        return serviceProviderInstances[namespace]?.trackerController
    }

    /// Set the passed tracker as default tracker if it's registered as an active tracker in the app.
    ///
    /// If the passed instance is of a tracker which is already removed (see `removeTracker`) then it can't become the new default tracker
    /// and the operation fails.
    ///
    /// - Parameter trackerController: The new default tracker.
    /// - Returns: Whether the tracker passed is registered among the active trackers of the app.
    @objc
    public class func setAsDefault(tracker trackerController: TrackerController?) -> Bool {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if let namespace = trackerController?.namespace,
           let serviceProvider = serviceProviderInstances[namespace] {
            defaultServiceProvider = serviceProvider
            return true
        }
        return false
    }

    /// Remove a tracker from the active trackers of the app.
    ///
    /// Once it has been removed it can't be added again or set as default.
    /// The unique way to resume a removed tracker is creating a new tracker with same namespace and
    /// same configurations.
    /// The removed tracker is always stopped.
    ///
    /// - Parameter trackerController: The tracker controller to remove.
    /// - Returns: Whether it has been able to remove it.
    @objc
    public class func remove(tracker trackerController: TrackerController?) -> Bool {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if let namespace = trackerController?.namespace,
           let serviceProvider = (serviceProviderInstances)[namespace] {
            serviceProvider.shutdown()
            serviceProviderInstances.removeValue(forKey: namespace)
            if serviceProvider == defaultServiceProvider {
                defaultServiceProvider = nil
            }
            return true
        }
        return false
    }

    /// Remove all the trackers.
    ///
    /// The removed tracker is always stopped.
    ///
    /// See ``remove(tracker:)`` to remove  a specific tracker.
    @objc
    public class func removeAllTrackers() {
        objc_sync_enter(self)
        defaultServiceProvider = nil
        let serviceProviders = serviceProviderInstances.values
        serviceProviderInstances.removeAll()
        for sp in serviceProviders {
            sp.shutdown()
        }
        objc_sync_exit(self)
    }

    /// - Returns: Set of namespace of the active trackers in the app.
    @objc
    class public var instancedTrackerNamespaces: [String] {
        return Array(serviceProviderInstances.keys)
    }

    #if os(iOS) || os(macOS)

    /// Subscribe to events tracked in a Web view using the Snowplow WebView tracker JavaScript library.
    ///
    /// - Parameter webViewConfiguration: Configuration of the Web view to subscribe to events from
    @objc
    public class func subscribeToWebViewEvents(with webViewConfiguration: WKWebViewConfiguration) {
        let messageHandler = WebViewMessageHandler()

        webViewConfiguration.userContentController.add(messageHandler, name: "snowplow")
    }

    #endif

    // MARK: - Private methods

    private class func registerInstance(_ serviceProvider: ServiceProvider) -> Bool {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        let namespace = serviceProvider.namespace
        let isOverriding = serviceProviderInstances[namespace] != nil
        serviceProviderInstances[namespace] = serviceProvider
        if defaultServiceProvider == nil {
            defaultServiceProvider = serviceProvider
        }
        return isOverriding
    }

    private class func createTrackers(configurationBundles bundles: [ConfigurationBundle]) -> [String] {
        var namespaces: [String]? = []
        for bundle in bundles {
            objc_sync_enter(self)
            if let networkConfiguration = bundle.networkConfiguration {
                if let _ = createTracker(
                    namespace: bundle.namespace,
                    network: networkConfiguration,
                    configurations: bundle.configurations) {
                    namespaces?.append(bundle.namespace)
                }
            } else {
                // remove tracker if it exists
                if let tracker = tracker(namespace: bundle.namespace) {
                    let _ = remove(tracker: tracker)
                }
            }
            objc_sync_exit(self)
        }
        return namespaces ?? []
    }
}
