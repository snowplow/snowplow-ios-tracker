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
@testable import SnowplowTracker

class TestServiceProvider: XCTestCase {
    override func setUp() {
        super.setUp()
        Logger.logLevel = .verbose
    }

    override func tearDown() {
        super.tearDown()
    }

    func testUpdatingConfigurationRetainsPausedEmitter() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let emitterConfig = EmitterConfiguration()
        emitterConfig.eventStore = MockEventStore()
        emitterConfig.bufferOption = .single
        let networkConfig = NetworkConfiguration(endpoint: "", method: .post)
        networkConfig.networkConnection = networkConnection
        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        trackerConfig.installAutotracking = false
        trackerConfig.screenViewAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        let serviceProvider = ServiceProvider(namespace: "serviceProviderTest",
                                              network: networkConfig,
                                              configurations: [emitterConfig, trackerConfig])
        XCTAssertNotNil(serviceProvider)

        // pause emitter
        serviceProvider.emitterController.pause()

        // refresh configuration
        serviceProvider.reset(configurations: [EmitterConfiguration()])

        // track event and check that emitter is paused
        InternalQueue.sync {
            _ = serviceProvider.trackerController.track(Structured(category: "cat", action: "act"))
        }
        Thread.sleep(forTimeInterval: 3)
        XCTAssertEqual(1, serviceProvider.emitter.dbCount)
        XCTAssertEqual(0, networkConnection.sendingCount)

        // resume emitting
        InternalQueue.sync {
            serviceProvider.emitterController.resume()
        }
        Thread.sleep(forTimeInterval: 3)
        XCTAssertEqual(1, networkConnection.sendingCount)
        XCTAssertEqual(0, serviceProvider.emitter.dbCount)
    }
    // TODO: fix logging and handle the case
    //- (void)testLogsErrorWhenAccessingShutDownTracker {
    //    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:200];
    //    SPEmitterConfiguration *emitterConfig = [[SPEmitterConfiguration alloc] init];
    //    emitterConfig.eventStore = [SPMockEventStore new];
    //    emitterConfig.bufferOption = SPBufferOptionSingle;
    //    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"" method:SPHttpMethodPost];
    //    networkConfig.networkConnection = networkConnection;
    //    SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNamespace:@"ns" network:networkConfig configurations:@[emitterConfig]];
    //    XCTAssertNotNil(serviceProvider);
    //
    //    // listen for the error log
    //    id<SPTrackerController> trackerController = [serviceProvider trackerController];
    //    SPMockLoggerDelegate *logger = [SPMockLoggerDelegate new];
    //    [trackerController setLoggerDelegate:logger];
    //
    //    // shutting down and accessing the tracker should log the error
    //    [serviceProvider shutdown];
    //    [trackerController namespace];
    //    XCTAssertEqual(1, [[logger errorLogs] count]);
    //    XCTAssertTrue([[[logger errorLogs] objectAtIndex:0] containsString:@"Recreating tracker instance"]);
    //}
}
