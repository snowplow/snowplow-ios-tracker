//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

/// Connects the tracker to a Snowplow Signals deployment, enabling `tracker.signals`.
///
/// Pass it to `Snowplow.createTracker` together with the other configurations:
///
/// ```swift
/// let tracker = Snowplow.createTracker(
///     namespace: "appTracker",
///     network: NetworkConfiguration(endpoint: "https://collector.example.com"),
///     configurations: [
///         SignalsConfiguration(endpoint: "https://signals.example.com")
///     ]
/// )
/// ```
///
/// Signals reads and intervention subscriptions are keyed on the session context entity identifiers,
/// so session tracking (`TrackerConfiguration.sessionContext`, on by default) must stay enabled
/// and `TrackerConfiguration.userAnonymisation` must stay disabled for the default identifiers to work.
@objc(SPSignalsConfiguration)
public class SignalsConfiguration: NSObject, ConfigurationProtocol {
    /// Default timeout for Signals HTTP requests, in seconds.
    static let defaultTimeout: TimeInterval = 5

    /// URL of the Signals API (the read plane, e.g. `https://xxx.signals.snowplowanalytics.com`).
    /// The `https://` scheme is assumed when none is given.
    @objc
    public private(set) var endpoint: String

    /// Timeout for reading service attributes, in seconds.
    @objc
    public var timeout: TimeInterval = SignalsConfiguration.defaultTimeout

    /// Creates a Signals configuration.
    /// - Parameter endpoint: URL of the Signals API. The `https://` scheme is assumed when none is given.
    @objc
    public init(endpoint: String) {
        self.endpoint = endpoint
        super.init()
    }

    /// Timeout for reading service attributes, in seconds.
    @objc
    public func timeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }

    /// The endpoint with a scheme and without a trailing slash, used as the base of all request URLs.
    var baseUrl: String {
        var url = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        if !url.contains("://") {
            url = "https://" + url
        }
        while url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }
}
