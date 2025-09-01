# Testing Guide - CLAUDE.md

## Testing Overview

The test suite for Snowplow iOS Tracker uses XCTest framework with extensive mocking and helper utilities. Tests are organized by functionality and follow consistent patterns for isolation, repeatability, and clarity. The suite covers unit tests, integration tests, and platform-specific scenarios.

**Framework**: XCTest
**Key Patterns**: Mock objects, Event sink, Time manipulation, Database helpers
**Organization**: Feature-based test grouping

## Test Architecture

```
Tests/
├── Tracker/           # Core tracker tests
├── Configurations/    # Configuration tests
├── Events/           # Event type tests
├── Ecommerce/        # E-commerce feature tests
├── Global Contexts/  # Context management tests
├── Legacy Tests/     # Backward compatibility
└── Utils/           # Test helpers & mocks
```

## Mock Patterns

### Network Mocking
```swift
// ✅ Use MockNetworkConnection
let network = MockNetworkConnection()
network.statusCode = 200
network.sendingCount = 0
let emitter = Emitter(networkConnection: network)

// ❌ Real network in tests
let emitter = Emitter(urlEndpoint: "http://real.com")
```

### Event Store Mocking
```swift
// ✅ Use MemoryEventStore for isolation
let store = MemoryEventStore()
let tracker = Tracker(eventStore: store)

// ❌ SQLite in unit tests
let store = SQLiteEventStore()  // Slow, requires cleanup
```

### Timer Mocking
```swift
// ✅ Use MockTimer for control
let timer = MockTimer()
session.foregroundTimeout = timer
timer.fire()  // Trigger manually

// ❌ Real timers with sleep
Timer.scheduledTimer(withTimeInterval: 1.0)
Thread.sleep(forTimeInterval: 1.5)
```

## Event Sink Pattern

### Capturing Events
```swift
// ✅ Use EventSink to capture
let sink = EventSink()
tracker.addStateMachine(sink.toStateMachine())
tracker.track(ScreenView(name: "test"))
XCTAssertEqual(sink.trackedEvents.count, 1)
XCTAssertEqual(sink.trackedEvents[0].schema, "screen_view")

// ❌ Database queries for verification
tracker.track(event)
let stored = store.getAllEvents()
XCTAssertEqual(stored.count, 1)
```

### Event Filtering
```swift
// ✅ Filter specific event types
let screenViews = sink.trackedEvents
    .filter { $0.schema.contains("screen_view") }
XCTAssertEqual(screenViews.count, 2)

// ❌ Complex database queries
let query = "SELECT * FROM events WHERE schema LIKE '%screen%'"
```

## Time Testing Patterns

### Time Travel
```swift
// ✅ Use TimeTraveler for time control
let traveler = TimeTraveler()
session.foregroundTimeout = 60
traveler.travel(by: 61)  // Advance time
XCTAssertTrue(session.isExpired)

// ❌ Thread.sleep for timing
Thread.sleep(forTimeInterval: 61)
```

### Date Mocking
```swift
// ✅ Inject date provider
class Session {
    var dateProvider: () -> Date = { Date() }
}
session.dateProvider = { testDate }

// ❌ Direct Date() calls
class Session {
    func check() {
        let now = Date()  // Can't control
    }
}
```

## Database Testing

### Test Database Setup
```swift
// ✅ Use DatabaseHelpers
let db = DatabaseHelpers.createTemporaryDatabase()
defer { DatabaseHelpers.cleanup(db) }

// ❌ Production database
let db = SQLiteEventStore(namespace: "test")
// May conflict with app data
```

### Database Assertions
```swift
// ✅ Helper methods for verification
XCTAssertEqual(
    DatabaseHelpers.countEvents(in: db),
    5
)

// ❌ Raw SQL in tests
let count = db.execute("SELECT COUNT(*) FROM events")
```

## Configuration Testing

### Isolated Configuration
```swift
// ✅ Create fresh configurations
func testConfiguration() {
    let config = TrackerConfiguration()
        .appId("test-app")
        .base64Encoding(false)
    
    XCTAssertEqual(config.appId, "test-app")
}

// ❌ Shared configuration state
let config = TrackerConfiguration.shared  // Side effects
```

### Configuration Merging
```swift
// ✅ Test configuration precedence
let remote = TrackerConfiguration().appId("remote")
let local = TrackerConfiguration().appId("local")
let merged = ConfigurationBundle.merge(remote, local)
XCTAssertEqual(merged.appId, "local")  // Local wins

// ❌ Assume merge behavior
let config = remote + local  // Undefined
```

## Async Testing

### Expectation Pattern
```swift
// ✅ Use XCTestExpectation
func testAsyncEmit() {
    let expectation = expectation(description: "emit")
    
    emitter.flush { success in
        XCTAssertTrue(success)
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 2.0)
}

// ❌ Sleep and check
emitter.flush()
Thread.sleep(forTimeInterval: 2.0)
XCTAssertTrue(emitter.isComplete)
```

### Completion Handlers
```swift
// ✅ Verify completion called
var completionCalled = false
tracker.track(event) { _ in
    completionCalled = true
}
XCTAssertTrue(completionCalled)

// ❌ Ignore completion
tracker.track(event) { _ in }
// Not verified
```

## Platform-Specific Testing

### Conditional Tests
```swift
// ✅ Skip unsupported platforms
#if os(iOS) || os(macOS)
func testWebViewIntegration() {
    // WebKit-specific test
}
#endif

// ❌ Runtime platform checks
func testWebView() {
    if #available(iOS 11.0, *) {
        // May run on wrong platform
    }
}
```

### Platform Mocks
```swift
// ✅ Mock platform-specific APIs
let deviceInfo = MockDeviceInfoMonitor()
deviceInfo.platform = "ios"
deviceInfo.osVersion = "15.0"

// ❌ Real device APIs
let version = UIDevice.current.systemVersion
```

## Test Organization

### Test Naming
```swift
// ✅ Descriptive test names
func testScreenView_WithCustomEntities_TracksEntitiesCorrectly() {
    // Clear what is being tested
}

// ❌ Generic names
func testEvent() {
    // Unclear purpose
}
```

### Test Structure
```swift
// ✅ Arrange-Act-Assert pattern
func testEmitterBatch() {
    // Arrange
    let emitter = createEmitter()
    let events = createEvents(count: 10)
    
    // Act
    events.forEach { emitter.add($0) }
    emitter.flush()
    
    // Assert
    XCTAssertEqual(network.sendCount, 1)
    XCTAssertEqual(network.batchSize, 10)
}

// ❌ Mixed concerns
func test() {
    let e = Emitter()
    e.add(Event())
    XCTAssert(e.count == 1)
    e.flush()
    // Unclear structure
}
```

## Common Testing Pitfalls

### 1. State Leakage
```swift
// ❌ Shared state between tests
class TestCase: XCTestCase {
    let tracker = createTracker()  // Shared
}

// ✅ Fresh state per test
override func setUp() {
    tracker = createTracker()
}
```

### 2. Timing Dependencies
```swift
// ❌ Fixed delays
Thread.sleep(forTimeInterval: 1.0)
XCTAssertTrue(completed)

// ✅ Explicit synchronization
let expectation = XCTestExpectation()
wait(for: [expectation], timeout: 1.0)
```

### 3. Resource Cleanup
```swift
// ❌ Missing cleanup
func testDatabase() {
    let db = createDatabase()
    // No cleanup
}

// ✅ Proper cleanup
func testDatabase() {
    let db = createDatabase()
    defer { db.close() }
}
```

## Performance Testing

### Measure Blocks
```swift
// ✅ Use measure for performance
func testBatchPerformance() {
    let events = createEvents(count: 1000)
    
    measure {
        events.forEach { tracker.track($0) }
    }
}

// ❌ Manual timing
let start = Date()
// ... code ...
let elapsed = Date().timeIntervalSince(start)
```

## Quick Reference

### Test Setup Checklist
- [ ] Create fresh tracker instance
- [ ] Use mock network connection
- [ ] Use memory event store
- [ ] Setup event sink if needed
- [ ] Configure mock timers
- [ ] Prepare test data

### Assertion Checklist
- [ ] Verify event count
- [ ] Check event properties
- [ ] Validate context entities
- [ ] Confirm network calls
- [ ] Test error conditions
- [ ] Verify cleanup

### Mock Utilities Available
- `MockNetworkConnection` - Network simulation
- `MockEventStore` - Storage testing
- `MockTimer` - Time control
- `EventSink` - Event capture
- `MockDeviceInfoMonitor` - Device info
- `TimeTraveler` - Time manipulation
- `DatabaseHelpers` - Database utilities