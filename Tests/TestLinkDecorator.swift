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

class TestLinkDecorator: XCTestCase {
    let epoch = "\\d{13}"
    
    let replacements = [".", "/", "?"]
    func matches(for regex: String, in text: String) {
        var regex = "^\(regex)$"
        
        do {
            for replacement in replacements {
                regex = regex.replacingOccurrences(of: replacement, with: "\\" + replacement)
            }
            let pattern = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = pattern.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            let fullMatch = results.map { nsString.substring(with: $0.range)}
            if (fullMatch.count == 0) {
                XCTFail("URL does not match pattern:\n\(text)\n\(regex)")
            }
            XCTAssertEqual(fullMatch.count, 1)
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
    }
    
    func testParameterConfiguration() {
        let tracker = getTracker()
        let _ = tracker.track(ScreenView(name: "test"))
        
        let link = URL(string: "https://example.com")!
        let userId = tracker.session!.userId!
        let sessionId = tracker.session!.sessionId!
        let subjectUserId = tracker.subject!.userId!.toBase64()
        let appId = tracker.appId.toBase64()
        let platform = devicePlatformToString(tracker.devicePlatform)
        let reason = "reason"
        let reasonb64 = reason.toBase64()
        
        // All false
        matches(
            for: "https://example.com?_sp=\(userId).\(epoch)",
            in: tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: false, sourceId: false))!.absoluteString
        )
        
        // Default
        matches(
            for: "https://example.com?_sp=\(userId).\(epoch).\(sessionId)..\(appId)",
            in: tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration())!.absoluteString
        )
        
        matches(
            for: "https://example.com?_sp=\(userId).\(epoch).\(sessionId).\(subjectUserId).\(appId)",
            in: tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(subjectUserId: true))!.absoluteString
        )
        
        matches(
            for: "https://example.com?_sp=\(userId).\(epoch).\(sessionId).\(subjectUserId).\(appId).\(platform)",
            in: tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(subjectUserId: true, sourcePlatform: true))!.absoluteString
        )
        
        matches(
            for: "https://example.com?_sp=\(userId).\(epoch).\(sessionId).\(subjectUserId).\(appId).\(platform).\(reasonb64)",
            in: tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(subjectUserId: true, sourcePlatform: true, reason: reason))!.absoluteString
        )
        
        matches(
            for: "https://example.com?_sp=\(userId).\(epoch).....\(reasonb64)",
            in: tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: false, sourceId: false, reason: reason))!.absoluteString
        )
    }
    
    func testWithExistingSpQueryParameter() {
        let tracker = getTracker()
        let link = URL(string: "https://example.com?_sp=test")!
        
        let result = tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: false, sourceId: false))!
        
        matches(for: "https://example.com?_sp=\(tracker.session!.userId!).\(epoch)", in: result.absoluteString)
    }
    
    func testWithOtherQueryParameters() {
        let tracker = getTracker()
        let link = URL(string: "https://example.com?a=a&b=b")!
        let userId = tracker.session!.userId!
        
        let result = tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: false, sourceId: false))!
        
        matches(for: "https://example.com?a=a&b=b&_sp=\(userId).\(epoch)", in: result.absoluteString)
    }
    
    func testExistingSpQueryParameterInMiddleOfOtherQueryParameters() {
        let tracker = getTracker()
        let link = URL(string: "https://example.com?a=a&_sp=test&b=b")!
        
        let result = tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: false, sourceId: false))!
        
        matches(for: "https://example.com?a=a&b=b&_sp=\(tracker.session!.userId!).\(epoch)", in: result.absoluteString)
    }
    
    func testMissingFields() {
        let tracker = getTrackerNoSubjectUserId()
        let link = URL(string: "https://example.com")!
        
        let result = tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: true, subjectUserId: true))!
        
        // Resulting _sp param will have nothing for:
        // - sessionId, as an event has not been tracked
        // - subjectUserId, as it has not been set
        matches(
            for: "https://example.com?_sp=\(tracker.session!.userId!).\(epoch)...\(tracker.appId.toBase64())",
            in: result.absoluteString
        )
    }
    
    func testMissingSessionUserId() {
        let tracker = getTrackerNoSessionUserId()
        let link = URL(string: "https://example.com")!
        
        let result = tracker.decorateLink(link, extendedParameters: CrossDeviceParameterConfiguration(sessionId: true, subjectUserId: true))
        
        XCTAssertNil(result)
    }
    
    var (emitterConfig, networkConfig, trackerConfig) = (
        EmitterConfiguration().eventStore(MockEventStore()).bufferOption(.single),
        NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200)),
        TrackerConfiguration().installAutotracking(false).screenViewAutotracking(false).lifecycleAutotracking(false).sessionContext(true)
    )
    
    func getTracker() -> TrackerController {
        let subjectConfig = SubjectConfiguration().userId("userId")
        
        let namespace = "testEmitter" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, emitterConfig, subjectConfig])!
    }
    
    private func getTrackerNoSubjectUserId() -> TrackerController {
        let namespace = "testEmitter" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, emitterConfig])!
    }
    
    private func getTrackerNoSessionUserId() -> TrackerController {
        trackerConfig.sessionContext = false
        
        let namespace = "testEmitter" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, emitterConfig])!
    }
}
