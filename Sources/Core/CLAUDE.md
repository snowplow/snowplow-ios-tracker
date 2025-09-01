# Core Implementation - CLAUDE.md

## Module Overview

The Core module contains the internal implementation of the Snowplow iOS tracker. This layer handles event processing, network communication, storage, state management, and platform-specific integrations. All Core components are internal and should not be directly accessed by SDK users.

**Key Components**: Tracker engine, Emitter, Event store, State machines, Internal queue
**Design Principles**: Thread safety, State-driven behavior, Protocol abstraction, Separation of concerns

## Core Architecture

```
Core/
├── Tracker/          # Central tracking engine
├── Emitter/          # Network communication
├── Storage/          # Event persistence
├── StateMachine/     # State management
├── InternalQueue/    # Thread synchronization
├── Session/          # User session tracking
├── Subject/          # User identification
└── Utils/           # Platform utilities
```

## Thread Safety Pattern

### InternalQueue Synchronization
```swift
// ✅ All mutations through InternalQueue
InternalQueue.sync {
    tracker.track(event)
    emitter.flush()
}

// ❌ Direct access from multiple threads
DispatchQueue.global().async {
    tracker.track(event)  // Race condition
}
```

### IQWrapper Pattern
```swift
// ✅ Thread-safe wrapper
class TrackerControllerIQWrapper: TrackerController {
    func track(_ event: Event) -> UUID? {
        InternalQueue.sync { controller.track(event) }
    }
}

// ❌ Expose internal controller
return serviceProvider.trackerController  // Not thread-safe
```

## Tracker Core Patterns

### Event Processing Pipeline
```swift
// ✅ Complete processing flow
func track(_ event: Event) -> UUID? {
    event.beginProcessing(withTracker: self)
    let trackerEvent = TrackerEvent(event, state)
    let payload = buildPayload(trackerEvent)
    eventStore.add(payload)
    event.endProcessing(withTracker: self)
    return trackerEvent.eventId
}

// ❌ Skip processing hooks
func track(_ event: Event) {
    eventStore.add(event.payload)  // Missing processing
}
```

### State Snapshot
```swift
// ✅ Capture state at track time
let snapshot = TrackerStateSnapshot(
    state: stateManager.currentState(),
    timestamp: Date()
)

// ❌ Reference mutable state
let state = stateManager.state  // May change
```

## Emitter Patterns

### Batch Processing
```swift
// ✅ Batch events for efficiency
class Emitter {
    func flush() {
        let batch = eventStore.getEvents(limit: bufferSize)
        sendBatch(batch)
    }
}

// ❌ Send events individually
for event in events {
    send(event)  // Inefficient
}
```

### Network Retry Logic
```swift
// ✅ Exponential backoff
func retryWithBackoff(attempt: Int) {
    let delay = min(pow(2, attempt), maxDelay)
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.retry()
    }
}

// ❌ Immediate retry
while !success {
    retry()  // Can overwhelm server
}
```

## Storage Patterns

### SQLite Event Store
```swift
// ✅ Prepared statements
let insert = "INSERT INTO events (id, data) VALUES (?, ?)"
sqlite3_prepare_v2(db, insert, -1, &stmt, nil)

// ❌ String concatenation
let query = "INSERT INTO events VALUES ('\(id)', '\(data)')"
// SQL injection risk
```

### Memory Event Store
```swift
// ✅ Testing only
#if DEBUG
let store = MemoryEventStore()
#endif

// ❌ Production use
let store = MemoryEventStore()  // Data loss on restart
```

## State Machine Implementation

### State Transitions
```swift
// ✅ Immutable state transitions
func transition(from: State?, event: Event) -> State? {
    switch (from, event) {
    case (nil, is ScreenView):
        return ScreenState(event)
    default:
        return from
    }
}

// ❌ Mutable state updates
var currentState: State?
func handle(event: Event) {
    currentState.update(event)  // Side effects
}
```

### State Machine Registration
```swift
// ✅ Add state machines at initialization
tracker.addStateMachine(LifecycleStateMachine())
tracker.addStateMachine(ScreenStateMachine())

// ❌ Add/remove during tracking
tracker.track(event)
tracker.addStateMachine(machine)  // May miss events
```

## Session Management

### Session Lifecycle
```swift
// ✅ Automatic session management
class Session {
    func checkAndUpdate() -> SessionState {
        if isExpired() {
            startNewSession()
        }
        updateAccessedAt()
        return currentState()
    }
}

// ❌ Manual session control
session.id = UUID()  // Breaks session continuity
```

### Session Storage
```swift
// ✅ Persist session state
UserDefaults.standard.set(
    sessionDict,
    forKey: "session_\(namespace)"
)

// ❌ Memory-only session
var session = Session()  // Lost on restart
```

## Subject (User) Patterns

### Platform Context
```swift
// ✅ Lazy platform detection
var platformDict: [String: Any] {
    if _platformDict == nil {
        _platformDict = DeviceInfoMonitor.dictionary()
    }
    return _platformDict!
}

// ❌ Eager initialization
init() {
    platformDict = DeviceInfoMonitor.dictionary()
    // Slow startup
}
```

### User Anonymization
```swift
// ✅ Respect anonymization setting
func getUserId() -> String? {
    guard !userAnonymisation else { return nil }
    return userId
}

// ❌ Always return user ID
func getUserId() -> String? {
    return userId  // Privacy violation
}
```

## Remote Configuration

### Configuration Fetching
```swift
// ✅ Cache with versioning
func fetchConfiguration() {
    let cached = cache.configuration
    fetch { remote in
        if remote.version > cached.version {
            cache.save(remote)
            apply(remote)
        }
    }
}

// ❌ Always use remote
fetch { config in
    apply(config)  // Ignores cache
}
```

## WebView Integration

### Message Handling
```swift
// ✅ Version-aware parsing
func userContentController(_ controller, didReceive message) {
    if message.name == "snowplowV2" {
        handleV2Message(message.body)
    } else {
        handleLegacyMessage(message.body)
    }
}

// ❌ Single version support
handleMessage(message.body)  // May break
```

## Platform-Specific Code

### Conditional Compilation
```swift
// ✅ Platform checks
#if os(iOS)
    import UIKit
    let screen = UIScreen.main
#elseif os(macOS)
    import AppKit
    let screen = NSScreen.main
#endif

// ❌ Runtime checks for compilation
if UIDevice.current != nil {  // Compile error on macOS
}
```

## Service Provider Pattern

### Dependency Injection
```swift
// ✅ Constructor injection
class ServiceProvider {
    init(namespace: String, network: NetworkConfiguration) {
        self.tracker = Tracker(namespace: namespace)
        self.emitter = Emitter(network: network)
    }
}

// ❌ Global singletons
class ServiceProvider {
    let tracker = Tracker.shared  // Hard to test
}
```

## Common Implementation Pitfalls

### 1. Circular Dependencies
```swift
// ❌ Circular reference
class Tracker {
    let emitter: Emitter
    init() {
        emitter = Emitter(tracker: self)  // Retain cycle
    }
}

// ✅ Weak references
class Emitter {
    weak var tracker: Tracker?
}
```

### 2. Resource Leaks
```swift
// ❌ Unclosed resources
sqlite3_open(path, &db)
// Missing sqlite3_close

// ✅ Proper cleanup
defer { sqlite3_close(db) }
sqlite3_open(path, &db)
```

### 3. Timer Management
```swift
// ❌ Unmanaged timers
Timer.scheduledTimer(withTimeInterval: 1.0) { _ in
    self.ping()
}

// ✅ Store and invalidate
self.timer = Timer.scheduledTimer(...)
deinit { timer?.invalidate() }
```

## Quick Reference

### Core Component Checklist
- [ ] Thread safety via InternalQueue
- [ ] Protocol-based abstraction
- [ ] Proper resource management
- [ ] Platform conditional compilation
- [ ] State machine for complex behavior
- [ ] Weak references to prevent cycles

### Implementation Guidelines
- [ ] Never expose Core types publicly
- [ ] Always use IQWrapper for controllers
- [ ] Implement proper cleanup in deinit
- [ ] Use dependency injection
- [ ] Cache expensive operations
- [ ] Handle all error cases