# Events Module - CLAUDE.md

## Module Overview

The Events module defines all trackable event types in the Snowplow iOS tracker. Events follow a class hierarchy with `Event` as the base class, supporting both self-describing and primitive event types. Each event encapsulates specific behavioral data and can carry additional context entities.

**Key Concepts**: Event inheritance, Self-describing schemas, Context entities, Event lifecycle
**Patterns**: Builder pattern, Template method, Protocol extensions

## Event Type Hierarchy

```
Event (Base)
├── SelfDescribingAbstract
│   ├── SelfDescribing (Generic)
│   ├── ScreenView
│   ├── Timing
│   └── [Domain Events]
└── PrimitiveAbstract
    ├── Structured
    ├── PageView
    └── [Legacy Events]
```

## Core Event Patterns

### Event Creation
```swift
// ✅ Use builders for configuration
let event = ScreenView(name: "Home")
    .entities([contextEntity])
    .trueTimestamp(Date())

// ❌ Mutation after creation
let event = ScreenView(name: "Home")
event.name = "Dashboard"  // Immutable after creation
```

### Self-Describing Events
```swift
// ✅ Proper schema and payload
let event = SelfDescribing(
    schema: "iglu:com.example/event/jsonschema/1-0-0",
    payload: ["key": "value"]
)

// ❌ Invalid schema format
let event = SelfDescribing(
    schema: "my-event",  // Must be full Iglu URI
    payload: data
)
```

### Context Entities
```swift
// ✅ Add entities at creation
let entity = SelfDescribingJson(
    schema: "iglu:com.example/context/jsonschema/1-0-0",
    data: ["userId": "123"]
)
event.entities([entity])

// ❌ Mutate entities collection
event.entities.append(entity)  // Use builder method
```

## Event Implementation Rules

### Custom Event Classes
```swift
// ✅ Extend appropriate base class
class CustomEvent: SelfDescribingAbstract {
    override var schema: String {
        return "iglu:com.example/custom/jsonschema/1-0-0"
    }
    override var payload: [String: Any] {
        return ["data": value]
    }
}

// ❌ Direct Event subclass for domain events
class CustomEvent: Event { }  // Use SelfDescribingAbstract
```

### Event Processing Hooks
```swift
// ✅ Override processing methods when needed
override func beginProcessing(withTracker tracker: Tracker) {
    super.beginProcessing(withTracker: tracker)
    // Pre-processing logic
}

// ❌ Modify state outside processing
func track() {
    self.timestamp = Date()  // Use processing hooks
}
```

## E-commerce Event Patterns

### Transaction Events
```swift
// ✅ Use specialized e-commerce events
let event = EcommerceTransaction(
    transactionId: "T12345",
    totalValue: 99.99
)

// ❌ Generic self-describing for standard events
let event = SelfDescribing(
    schema: "iglu:com.snowplow/transaction/...",
    payload: [:]
)  // Use EcommerceTransaction
```

## Screen Tracking Events

### Screen View Events
```swift
// ✅ Track screen transitions
let event = ScreenView(name: "ProductDetail")
    .type("detail")
    .screenId(UUID())

// ❌ Use generic events for screens
let event = SelfDescribing(
    schema: "screen_schema",
    payload: ["name": "ProductDetail"]
)
```

### Screen End Events
```swift
// ✅ Automatic screen end tracking
// Handled by ScreenStateMachine internally

// ❌ Manual screen end events
let event = ScreenEnd()  // Internal use only
tracker.track(event)
```

## Lifecycle Events

### Foreground/Background
```swift
// ✅ Automatic lifecycle tracking
TrackerConfiguration()
    .lifecycleAutotracking(true)

// ❌ Manual lifecycle events in app
let event = Foreground()  // Auto-tracked
tracker.track(event)
```

## Error & Diagnostic Events

### Error Tracking
```swift
// ✅ Use SNOWError for error tracking
let error = SNOWError(message: "Failed to load")
    .errorCode("E001")
    .stackTrace(trace)

// ❌ Generic events for errors
let event = Structured(
    category: "error",
    action: "occurred"
)
```

## Media Events

### Media Player Events
```swift
// ✅ Use media-specific events
let event = MediaPlayEvent()
    .label("video-1")
    .currentTime(30.5)

// ❌ Structured events for media
let event = Structured(
    category: "media",
    action: "play"
)
```

## Platform-Specific Events

### iOS/macOS WebView Events
```swift
#if os(iOS) || os(macOS)
// ✅ Handle WebView events
let event = WebViewReader.parseMessage(message)
#endif

// ❌ WebView events on unsupported platforms
let event = WebViewReader.parse()  // Platform check required
```

### visionOS Immersive Events
```swift
#if os(visionOS)
// ✅ Track immersive space events
let event = ImmersiveSpaceEvent(
    id: "space-1",
    style: .mixed
)
#endif
```

## Event Validation

### Schema Validation
```swift
// ✅ Validate before tracking
guard event.schema.hasPrefix("iglu:") else {
    return nil  // Invalid schema
}

// ❌ Track without validation
tracker.track(event)  // May fail silently
```

### Required Fields
```swift
// ✅ Check required fields
class CustomEvent: SelfDescribingAbstract {
    init?(requiredField: String) {
        guard !requiredField.isEmpty else { return nil }
        self.field = requiredField
    }
}

// ❌ Allow empty required fields
init(requiredField: String = "")
```

## Common Pitfalls

### 1. Event Reuse
```swift
// ❌ Reuse event instances
let event = ScreenView(name: "Home")
tracker.track(event)
tracker.track(event)  // Same event ID

// ✅ Create new instances
tracker.track(ScreenView(name: "Home"))
tracker.track(ScreenView(name: "Home"))
```

### 2. Timing Issues
```swift
// ❌ Set timestamp after creation
let event = ScreenView(name: "Home")
Thread.sleep(1)
event.trueTimestamp = Date()  // Too late

// ✅ Set timestamp at creation
let event = ScreenView(name: "Home")
    .trueTimestamp(Date())
```

### 3. Entity Array Mutation
```swift
// ❌ Direct array manipulation
event.entities.append(newEntity)

// ✅ Use builder method
event.entities([entity1, entity2])
```

## Quick Reference

### Event Creation Checklist
- [ ] Choose correct base class (SelfDescribing vs Primitive)
- [ ] Implement required properties (schema, payload)
- [ ] Add context entities if needed
- [ ] Set trueTimestamp for historical events
- [ ] Validate schema format (Iglu URI)

### Custom Event Checklist
- [ ] Extend appropriate abstract class
- [ ] Override schema property
- [ ] Override payload property
- [ ] Implement init with required fields
- [ ] Add builder methods for optional fields
- [ ] Consider processing hooks if needed