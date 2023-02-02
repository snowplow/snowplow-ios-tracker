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

import XCTest
import Mocker
@testable import SnowplowTracker

class TestRemoteConfiguration: XCTestCase {
    override func tearDown() {
        Mocker.removeAll()
    }
    
    func testJSONToConfigurations() {
        let config = """
            {"$schema":"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0","configurationVersion":12,"configurationBundle": [\
                {"namespace": "default1",\
                "networkConfiguration": {"endpoint":"https://fake.snowplow.io","method":"get"},\
                "trackerConfiguration": {"applicationContext":false,"screenContext":false,},\
                "sessionConfiguration": {"backgroundTimeout":60,"foregroundTimeout":60}\
                },\
                {"namespace": "default2",\
                "subjectConfiguration": {"userId":"testUserId"}\
                }\
                ]}
            """
        guard let jsonData = config.data(using: .utf8) else {
            return XCTFail()
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] else {
            return XCTFail()
        }
        guard let fetchedConfigurationBundle = FetchedConfigurationBundle(dictionary: dictionary) else {
            return XCTFail()
        }
        XCTAssertEqual("http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", fetchedConfigurationBundle.schema)
        XCTAssertEqual(12, fetchedConfigurationBundle.configurationVersion)
        XCTAssertEqual(2, fetchedConfigurationBundle.configurationBundle.count)

        // Regular setup
        var configurationBundle = fetchedConfigurationBundle.configurationBundle[0]
        XCTAssertEqual("default1", configurationBundle.namespace)
        XCTAssertNotNil(configurationBundle.networkConfiguration)
        XCTAssertNotNil(configurationBundle.trackerConfiguration)
        XCTAssertNotNil(configurationBundle.sessionConfiguration)
        XCTAssertNil(configurationBundle.subjectConfiguration)
        let networkConfiguration = configurationBundle.networkConfiguration
        XCTAssertEqual(.get, networkConfiguration?.method)
        guard let trackerConfiguration = configurationBundle.trackerConfiguration else { return XCTFail() }
        XCTAssertFalse(trackerConfiguration.applicationContext)
        let sessionConfiguration = configurationBundle.sessionConfiguration
        XCTAssertEqual(60, sessionConfiguration?.backgroundTimeoutInSeconds)

        // Regular setup without NetworkConfiguration
        configurationBundle = fetchedConfigurationBundle.configurationBundle[1]
        XCTAssertEqual("default2", configurationBundle.namespace)
        XCTAssertNil(configurationBundle.networkConfiguration)
        XCTAssertNotNil(configurationBundle.subjectConfiguration)
        let subjectConfiguration = configurationBundle.subjectConfiguration
        XCTAssertEqual("testUserId", subjectConfiguration?.userId)
    }

#if !os(watchOS) // Mocker seems not to currently work on watchOS
    func testDownloadConfiguration() {
        let endpoint = "https://fake-snowplow.io/config.json"

        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [
            .get: "{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0\",\"configurationVersion\":12,\"configurationBundle\":[]}".data(using: .utf8)!
        ])
        mock.register()
        
        let expectation = XCTestExpectation()

        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)
        _ = ConfigurationFetcher(remoteSource: remoteConfig, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTAssertNotNil(fetchedConfigurationBundle)
            XCTAssertEqual("http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", fetchedConfigurationBundle.schema)
            XCTAssertEqual(.fetched, configurationState)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10)
    }
#endif

#if os(iOS) || os(macOS)
    func testCache() {
        let bundle = ConfigurationBundle(namespace: "namespace", networkConfiguration: NetworkConfiguration(endpoint: "endpoint"))
        let expected = FetchedConfigurationBundle(schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", configurationVersion: 12)
        expected.configurationBundle = [bundle]

        let remoteConfig = RemoteConfiguration(endpoint: "http://example.com", method: .get)

        var cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        cache.clear()
        cache.write(expected)

        Thread.sleep(forTimeInterval: 5) // wait the config is written on cache.

        cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        let config = cache.read()

        XCTAssertEqual(expected.configurationVersion, config?.configurationVersion)
        XCTAssertEqual(expected.schema, config?.schema)
        XCTAssertEqual(expected.configurationBundle.count, config?.configurationBundle.count)
        let expectedBundle = expected.configurationBundle[0]
        let configBundle = config?.configurationBundle[0]
        XCTAssertEqual(expectedBundle.networkConfiguration?.endpoint, configBundle?.networkConfiguration?.endpoint)
        XCTAssertNil(configBundle?.trackerConfiguration)
    }
#endif

    func testProvider_notDownloading_fails() {
        // prepare test
        let endpoint = "https://fake-snowplow.io/config.json"
        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)
        let cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        cache.clear()
        
        // mock endpoint
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 404, data: [.get: Data()])
        mock.register()
        
        // test
        let expectation = XCTestExpectation()
        let provider = ConfigurationProvider(remoteConfiguration: remoteConfig)
        provider.retrieveConfigurationOnlyRemote(false, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTFail()
        })
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(XCTWaiter.Result.timedOut, result)
    }

    func testProvider_downloadOfWrongSchema_fails() {
        // prepare test
        let endpoint = "https://fake-snowplow.io/config.json"
        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)
        let cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        cache.clear()

        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [
            .get: "{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/2-0-0\",\"configurationVersion\":12,\"configurationBundle\":[]}".data(using: .utf8)!
        ])
        mock.register()
        
        // test
        let expectation = XCTestExpectation()
        let provider = ConfigurationProvider(remoteConfiguration: remoteConfig)
        provider.retrieveConfigurationOnlyRemote(false, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTFail()
        })
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(XCTWaiter.Result.timedOut, result)
    }

#if os(iOS) || os(macOS)
    func testProvider_downloadSameConfigVersionThanCached_dontUpdate() {
        // prepare test
        let endpoint = "https://fake-snowplow.io/config.json"
        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)

        let cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        cache.clear()
        let bundle = ConfigurationBundle(namespace: "namespace", networkConfiguration: NetworkConfiguration(endpoint: "endpoint"))
        let cached = FetchedConfigurationBundle(schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", configurationVersion: 1)
        cached.configurationBundle = [bundle]
        cache.write(cached)
        Thread.sleep(forTimeInterval: 5) // wait to write on cache

        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [
            .get: "{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":1,\"configurationBundle\":[]}".data(using: .utf8)!
        ])
        mock.register()

        // test
        let expectation = XCTestExpectation()
        let provider = ConfigurationProvider(remoteConfiguration: remoteConfig)
        var i = 0
        provider.retrieveConfigurationOnlyRemote(false, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTAssertEqual(.cached, configurationState)
            if i == 1 || (fetchedConfigurationBundle.schema == "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0") {
                XCTFail()
            }
            if i == 0 && (fetchedConfigurationBundle.schema == "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0") {
                i += 1
            }
        })
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(XCTWaiter.Result.timedOut, result)
        XCTAssertEqual(1, i)
    }

    func testProvider_downloadHigherConfigVersionThanCached_doUpdate() {
        // prepare test
        let endpoint = "https://fake-snowplow.io/config.json"
        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)

        let cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        cache.clear()
        let bundle = ConfigurationBundle(namespace: "namespace", networkConfiguration: NetworkConfiguration(endpoint: "endpoint"))
        let cached = FetchedConfigurationBundle(schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", configurationVersion: 1)
        cached.configurationBundle = [bundle]
        cache.write(cached)
        Thread.sleep(forTimeInterval: 5) // wait to write on cache
        
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [
            .get: "{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":2,\"configurationBundle\":[]}".data(using: .utf8)!
        ])
        mock.register()

        // test
        let expectation = XCTestExpectation()
        let provider = ConfigurationProvider(remoteConfiguration: remoteConfig)
        var i = 0
        provider.retrieveConfigurationOnlyRemote(false, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTAssertEqual(
                i == 0 ? .cached : .fetched,
                configurationState)
            if i == 1 && (fetchedConfigurationBundle.schema == "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0") {
                i += 1
            }
            if i == 0 && (fetchedConfigurationBundle.schema == "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0") {
                i += 1
            }
        })
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(XCTWaiter.Result.timedOut, result)
        XCTAssertEqual(2, i)
    }

    func testProvider_justRefresh_downloadSameConfigVersionThanCached_dontUpdate() {
        // prepare test
        let endpoint = "https://fake-snowplow.io/config.json"
        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)

        let cache = ConfigurationCache(remoteConfiguration: remoteConfig)
        cache.clear()
        let bundle = ConfigurationBundle(namespace: "namespace", networkConfiguration: NetworkConfiguration(endpoint: "endpoint"))
        let cached = FetchedConfigurationBundle(schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", configurationVersion: 1)
        cached.configurationBundle = [bundle]
        cache.write(cached)
        Thread.sleep(forTimeInterval: 5) // wait to write on cache
        
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [
            .get: "{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":1,\"configurationBundle\":[]}".data(using: .utf8)!
        ])
        mock.register()

        // test
        let provider = ConfigurationProvider(remoteConfiguration: remoteConfig)
        var expectation = XCTestExpectation()
        provider.retrieveConfigurationOnlyRemote(false, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTAssertEqual(.cached, configurationState)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)

        expectation = XCTestExpectation()
        provider.retrieveConfigurationOnlyRemote(true, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTFail()
        })
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(XCTWaiter.Result.timedOut, result)
    }

    func testDoesntUseCachedConfigurationIfDifferentRemoteEndpoint() {
        // prepare test
        let endpoint = "https://fake-snowplow.io/config.json"
        let cachedRemoteConfig = RemoteConfiguration(endpoint: "https://cached-snowplow.io/config.json", method: .get)
        let remoteConfig = RemoteConfiguration(endpoint: endpoint, method: .get)

        // write configuration (version 2) to cache
        let cache = ConfigurationCache(remoteConfiguration: cachedRemoteConfig)
        cache.clear()
        let bundle = ConfigurationBundle(namespace: "namespace", networkConfiguration: NetworkConfiguration(endpoint: "endpoint"))
        let cached = FetchedConfigurationBundle(schema: "http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", configurationVersion: 2)
        cached.configurationBundle = [bundle]
        cache.write(cached)
        Thread.sleep(forTimeInterval: 5) // wait to write on cache

        // stub request for configuration (return version 1)
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [
            .get: "{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":1,\"configurationBundle\":[]}".data(using: .utf8)!
        ])
        mock.register()

        // initialize tracker with remote config
        let expectation = XCTestExpectation()
        _ = ConfigurationFetcher(remoteSource: remoteConfig, onFetchCallback: { fetchedConfigurationBundle, configurationState in
            XCTAssertNotNil(fetchedConfigurationBundle)
            // should be the non-cache configuration (version 1)
            XCTAssertEqual("http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0", fetchedConfigurationBundle.schema)
            XCTAssertEqual(1, fetchedConfigurationBundle.configurationVersion)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10)
    }
    
#endif
    
    // TODO: Replace LSNocilla as it's unreliable and unsupported. It causes this test failure.
    /*
    - (void)testConfigurationProvider_justRefresh_downloadHigherConfigVersionThanCached_doUpdate {
        // prepare test
        NSString *endpoint = @"https://fake-snowplow.io/config.json";
        SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];

        SPConfigurationCache *cache = [[SPConfigurationCache alloc] initWithRemoteConfiguration:remoteConfig];
        [cache clearCache];
        SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] init];
        bundle.networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"];
        SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
        cached.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
        cached.configurationVersion = 1;
        cached.configurationBundle = @[bundle];
        [cache writeCache:cached];
        [NSThread sleepForTimeInterval:5]; // wait to write on cache

        SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
        XCTestExpectation *expectation = [XCTestExpectation new];
        [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
            [expectation fulfill];
        }];
        [self waitForExpectations:@[expectation] timeout:5];

        [[LSNocilla sharedInstance] start];
        stubRequest(@"GET", endpoint)
        .andReturn(200)
        .withHeaders(@{@"Content-Type": @"application/json"})
        .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":2,\"configurationBundle\":[]}");

        // test
        expectation = [XCTestExpectation new];
        __block int i = 0;
        [provider retrieveConfigurationOnlyRemote:YES onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
            if ([fetchedConfigurationBundle.schema isEqualToString:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0"]) {
                i++;
            }
        }];
        XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
        XCTAssertEqual(XCTWaiterResultTimedOut, result);
        XCTAssertEqual(1, i);

        // close test
        [[LSNocilla sharedInstance] stop];
    }
    */
}
