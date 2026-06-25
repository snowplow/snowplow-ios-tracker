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

import XCTest
@testable import SnowplowTracker

/// A `RequestCallback` for emitter tests that replaces `Thread.sleep`-based waits with
/// deterministic synchronization. The emitter invokes `onSuccess`/`onFailure` after every
/// processed request batch (on the InternalQueue, once an emit run settles), so a test can
/// wait for the exact number of events to have been accounted for instead of guessing how
/// long the async emit + event-store drain takes.
///
/// Counts are cumulative across batches within an emit run, which is what the old
/// `dbCount`-after-sleep assertions were really a proxy for: once N events have been
/// reported as processed, the store has settled into its expected state.
class EmitterEventProcessedCallback: NSObject, RequestCallback {
    private let lock = NSLock()

    private var _successCount = 0
    private var _failureCount = 0

    /// Caller-supplied predicate over (success, failure) counts; when it first returns true
    /// the pending expectation (if any) is fulfilled.
    private var predicate: ((_ success: Int, _ failure: Int) -> Bool)?
    private var pendingExpectation: XCTestExpectation?

    var successCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _successCount
    }

    var failureCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _failureCount
    }

    /// Returns an expectation that fulfills once the cumulative counts satisfy `predicate`.
    /// If the predicate is already satisfied by counts seen so far, the expectation is
    /// fulfilled immediately, avoiding a lost-wakeup race.
    func expect(description: String = "Emitter processed events",
                where predicate: @escaping (_ success: Int, _ failure: Int) -> Bool) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: description)
        lock.lock()
        if predicate(_successCount, _failureCount) {
            lock.unlock()
            expectation.fulfill()
        } else {
            self.predicate = predicate
            self.pendingExpectation = expectation
            lock.unlock()
        }
        return expectation
    }

    /// Convenience: wait until at least `count` events have been processed (success or failure).
    func expectProcessed(_ count: Int) -> XCTestExpectation {
        return expect(description: "Emitter processed \(count) events") { success, failure in
            success + failure >= count
        }
    }

    /// Convenience: wait until at least `count` events have been successfully sent.
    func expectSuccesses(_ count: Int) -> XCTestExpectation {
        return expect(description: "Emitter sent \(count) events successfully") { success, _ in
            success >= count
        }
    }

    private func record(success: Int, failure: Int) {
        lock.lock()
        _successCount += success
        _failureCount += failure
        if let predicate = predicate, predicate(_successCount, _failureCount) {
            let expectation = pendingExpectation
            self.predicate = nil
            self.pendingExpectation = nil
            lock.unlock()
            expectation?.fulfill()
        } else {
            lock.unlock()
        }
    }

    // MARK: - RequestCallback

    func onSuccess(withCount successCount: Int) {
        record(success: successCount, failure: 0)
    }

    func onFailure(withCount failureCount: Int, successCount: Int) {
        record(success: successCount, failure: failureCount)
    }
}
