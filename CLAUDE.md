# Snowplow iOS Tracker - CLAUDE.md

## Project Overview

The Snowplow iOS Tracker is a comprehensive analytics SDK that enables event tracking across iOS, macOS, tvOS, and watchOS platforms. It follows a modular architecture with clear separation between core tracking logic, event definitions, network communication, and platform-specific features. The tracker sends behavioral data to Snowplow collectors for real-time analytics processing.

**Key Technologies**: Swift 5.3+, UIKit/SwiftUI, WebKit, SQLite, Foundation Framework
**Platforms**: iOS 11.0+, macOS 10.13+, tvOS 12.0+, watchOS 6.0+
**Architecture**: Event-driven, State Machine based, Protocol-oriented

## Development Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Run specific test
swift test --filter TestTracker

# Generate documentation
swift package generate-documentation

# Update dependencies
swift package update

# Clean build artifacts
swift package clean

# Create xcodeproj for development
swift package generate-xcodeproj
```

## Architecture

The tracker follows a layered architecture with clear boundaries:

```
Snowplow (Public API Layer)
    ├── Configurations (Setup & Config)
    ├── Events (Event Definitions)
    ├── Controllers (Runtime Control)
    └── Entities (Data Models)
    
Core (Internal Implementation)
    ├── Tracker (Core Logic)
    ├── Emitter (Network Layer)
    ├── Storage (Persistence)
    ├── StateMachine (State Management)
    └── InternalQueue (Thread Safety)
```

## Core Architectural Principles

### 1. Protocol-Oriented Design
All major components use protocols for abstraction:
```swift
// ✅ Define capability through protocols
public protocol TrackerController: AnyObject {
    var namespace: String { get }
    func track(_ event: Event) -> UUID?
}

// ❌ Avoid concrete types in public APIs
class Tracker { } // Should be behind protocol
```

### 2. State Machine Pattern
Complex behaviors managed through state machines:
```swift
// ✅ State transitions for lifecycle events
class LifecycleStateMachine: StateMachineProtocol {
    func transition(from: State, event: Event) -> State?
}

// ❌ Ad-hoc state management
var isBackground = false // Use state machine instead
```

### 3. Thread Safety via InternalQueue
All mutations happen on a serial queue:
```swift
// ✅ Thread-safe access
InternalQueue.sync {
    serviceProvider.trackerController.track(event)
}

// ❌ Direct access from multiple threads
tracker.track(event) // Not thread-safe
```

### 4. Builder Pattern for Configuration
Configurations use builder pattern for flexibility:
```swift
// ✅ Fluent configuration
let tracker = Snowplow.createTracker(namespace: "ns1", endpoint: "url") {
    TrackerConfiguration()
        .appId("app-id")
        .base64Encoding(false)
}

// ❌ Multiple setter calls
tracker.appId = "app-id"
tracker.base64 = false
```

## Layer Organization & Responsibilities

### Sources/Snowplow (Public API)
- **Purpose**: User-facing API and contracts
- **Contents**: Events, Configurations, Controllers, Entities
- **Dependencies**: Only Core layer
- **Key Pattern**: All types marked with `@objc` for Objective-C compatibility

### Sources/Core (Implementation)
- **Purpose**: Internal implementation details
- **Contents**: Tracker logic, Storage, Networking, State machines
- **Dependencies**: Foundation, SQLite
- **Key Pattern**: Internal visibility, not exposed to SDK users

### Tests
- **Purpose**: Unit and integration testing
- **Contents**: Test cases, Mocks, Helpers
- **Key Pattern**: XCTest framework, Mock implementations for isolation

## Critical Import Patterns

```swift
// ✅ Public API imports
import SnowplowTracker

// ✅ Internal implementation imports
@testable import SnowplowTracker  // Tests only

// ✅ Platform-specific imports
#if os(iOS) || os(macOS)
import WebKit
#endif

// ❌ Never import Core directly
import Core  // Internal only
```

## Essential Event Patterns

### Event Hierarchy
```swift
// ✅ Base class for all events
class Event: NSObject {
    var entities: [SelfDescribingJson]
    var trueTimestamp: Date?
}

// ✅ Self-describing events
class SelfDescribing: SelfDescribingAbstract {
    let schema: String
    let payload: [String: Any]
}

// ❌ Events without base class
struct CustomEvent { }  // Must inherit from Event
```

### Event Tracking
```swift
// ✅ Track with entities
let event = ScreenView(name: "Home")
    .entities([SelfDescribingJson(schema: "...", data: [:])])
tracker.track(event)

// ❌ Mutate after tracking
let event = ScreenView(name: "Home")
tracker.track(event)
event.entities = []  // Too late
```

## Configuration Patterns

### Network Configuration
```swift
// ✅ Configure network properly
NetworkConfiguration(endpoint: "https://collector.example.com")
    .method(.post)
    .customPostPath("/com.snowplow/tp2")

// ❌ Insecure endpoints in production
NetworkConfiguration(endpoint: "http://collector.example.com")
```

### Tracker Configuration
```swift
// ✅ Enable appropriate contexts
TrackerConfiguration()
    .sessionContext(true)
    .platformContext(true)
    .applicationContext(true)

// ❌ Track everything by default
TrackerConfiguration()  // Be explicit about requirements
```

## Storage & Persistence Patterns

### Event Store
```swift
// ✅ Use appropriate event store
let store = SQLiteEventStore(namespace: namespace)  // Production
let store = MemoryEventStore()  // Testing only

// ❌ Hardcode storage implementation
let store = SQLiteEventStore()  // Always use namespace
```

## State Machine Patterns

```swift
// ✅ Implement state machines for complex state
class ScreenStateMachine: StateMachineProtocol {
    func transition(from: State?, event: Event) -> State?
}

// ❌ Manual state tracking
var screenState: String = "unknown"
```

## Testing Patterns

### Mock Network Connection
```swift
// ✅ Use mocks for testing
let connection = MockNetworkConnection()
connection.statusCode = 200

// ❌ Test against real endpoints
let connection = DefaultNetworkConnection(url)
```

### Event Sink Pattern
```swift
// ✅ Capture events for assertions
let sink = EventSink()
tracker.addStateMachine(sink.toStateMachine())
XCTAssertEqual(sink.trackedEvents.count, 1)

// ❌ Sleep-based assertions
Thread.sleep(forTimeInterval: 1.0)
```

## Common Pitfalls & Solutions

### 1. Namespace Conflicts
```swift
// ❌ Reusing namespaces
let t1 = createTracker(namespace: "app")
let t2 = createTracker(namespace: "app")  // Overwrites t1

// ✅ Unique namespaces
let t1 = createTracker(namespace: "app-main")
let t2 = createTracker(namespace: "app-analytics")
```

### 2. Memory Leaks
```swift
// ❌ Strong reference cycles
globalContext.generator = { [self] in
    return self.generateContext()
}

// ✅ Weak references in closures
globalContext.generator = { [weak self] in
    return self?.generateContext()
}
```

### 3. Thread Safety
```swift
// ❌ Direct property access
tracker.appId = "new-id"

// ✅ Use controller methods
trackerController.appId = "new-id"  // Thread-safe
```

## File Structure Template

```
snowplow-ios-tracker/
├── Sources/
│   ├── Snowplow/           # Public API
│   │   ├── Snowplow.swift  # Main entry point
│   │   ├── Events/         # Event definitions
│   │   ├── Configurations/ # Setup configs
│   │   ├── Controllers/    # Runtime control
│   │   └── Entities/       # Data models
│   └── Core/               # Internal implementation
│       ├── Tracker/        # Core tracking logic
│       ├── Emitter/        # Network layer
│       ├── Storage/        # Persistence
│       └── StateMachine/   # State management
├── Tests/
│   ├── Tracker/           # Core tests
│   ├── Configurations/    # Config tests
│   ├── Events/           # Event tests
│   └── Utils/            # Test helpers
└── Package.swift         # Package definition
```

## Quick Reference

### Event Tracking Checklist
- [ ] Choose appropriate event type (ScreenView, Structured, SelfDescribing)
- [ ] Add required entities/contexts
- [ ] Set trueTimestamp if needed
- [ ] Validate schema for self-describing events
- [ ] Handle tracking result (UUID or nil)

### Configuration Checklist
- [ ] Set unique namespace
- [ ] Configure network endpoint
- [ ] Enable required contexts
- [ ] Set appropriate log level
- [ ] Configure session settings
- [ ] Setup subject properties

### Testing Checklist
- [ ] Use MockNetworkConnection
- [ ] Implement EventSink for assertions
- [ ] Test with MemoryEventStore
- [ ] Verify thread safety
- [ ] Check memory leaks
- [ ] Test platform-specific features

## WebView Integration

```swift
// ✅ Subscribe to WebView events
#if os(iOS) || os(macOS)
Snowplow.subscribeToWebViewEvents(with: webView.configuration)
#endif

// ❌ Manual JavaScript bridge
webView.evaluateJavaScript("trackEvent(...)")
```

## Platform-Specific Patterns

### iOS/macOS Only
```swift
#if os(iOS) || os(macOS)
// WebKit integration
// Screen view autotracking
#endif
```

### visionOS Support
```swift
#if os(visionOS)
// Immersive space tracking
// 3D interaction events
#endif
```

## Contributing to CLAUDE.md

When adding or updating content in this document, please follow these guidelines:

### File Size Limit
- **CLAUDE.md must not exceed 40KB** (currently ~19KB)
- Check file size after updates: `wc -c CLAUDE.md`
- Remove outdated content if approaching the limit

### Code Examples
- Keep all code examples **4 lines or fewer**
- Focus on the essential pattern, not complete implementations
- Use `// ❌` and `// ✅` to clearly show wrong vs right approaches

### Content Organization
- Add new patterns to existing sections when possible
- Create new sections sparingly to maintain structure
- Update the architectural principles section for major changes
- Ensure examples follow current codebase conventions

### Quality Standards
- Test any new patterns in actual code before documenting
- Verify imports and syntax are correct for the codebase
- Keep language concise and actionable
- Focus on "what" and "how", minimize "why" explanations

### Multiple CLAUDE.md Files
- **Directory-specific CLAUDE.md files** can be created for specialized modules
- Follow the same structure and guidelines as this root CLAUDE.md
- Keep them focused on directory-specific patterns and conventions
- Maximum 20KB per directory-specific CLAUDE.md file

### Instructions for LLMs
When editing files in this repository, **always check for CLAUDE.md guidance**:

1. **Look for CLAUDE.md in the same directory** as the file being edited
2. **If not found, check parent directories** recursively up to project root
3. **Follow the patterns and conventions** described in the applicable CLAUDE.md
4. **Prioritize directory-specific guidance** over root-level guidance when conflicts exist

This Contributing section must be included at the end of every root CLAUDE.md file.