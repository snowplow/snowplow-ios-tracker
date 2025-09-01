# Configurations Module - CLAUDE.md

## Module Overview

The Configurations module provides a declarative API for setting up Snowplow trackers. It uses the builder pattern with protocol-based configuration objects that can be composed, serialized, and applied at runtime or through remote configuration. Each configuration type controls a specific aspect of tracker behavior.

**Key Patterns**: Builder pattern, Protocol composition, Configuration merging, Serialization
**Core Types**: TrackerConfiguration, NetworkConfiguration, EmitterConfiguration, SessionConfiguration

## Configuration Hierarchy

```
ConfigurationProtocol (Base)
├── TrackerConfiguration     # Core tracker settings
├── NetworkConfiguration     # Collector endpoint
├── EmitterConfiguration     # Batching & sending
├── SessionConfiguration     # Session management
├── SubjectConfiguration     # User properties
├── GDPRConfiguration       # Privacy settings
└── GlobalContextsConfiguration # Context generators
```

## Configuration Patterns

### Builder Pattern Usage
```swift
// ✅ Fluent configuration
let tracker = Snowplow.createTracker(
    namespace: "app",
    endpoint: "https://collector.com"
) {
    TrackerConfiguration()
        .appId("my-app")
        .base64Encoding(false)
    SessionConfiguration(
        foregroundTimeout: 300,
        backgroundTimeout: 150
    )
}

// ❌ Imperative configuration
let tracker = createTracker()
tracker.appId = "my-app"
tracker.base64 = false
```

### Configuration Composition
```swift
// ✅ Multiple configurations
let configs: [ConfigurationProtocol] = [
    TrackerConfiguration(),
    NetworkConfiguration(endpoint: url),
    EmitterConfiguration(),
    SessionConfiguration()
]

// ❌ Mixed configuration types
let config = TrackerConfiguration()
config.networkEndpoint = url  // Wrong layer
```

## TrackerConfiguration

### Core Properties
```swift
// ✅ Essential tracker settings
TrackerConfiguration()
    .appId("com.example.app")
    .devicePlatform(.mobile)
    .base64Encoding(true)
    .logLevel(.debug)

// ❌ Missing required settings
TrackerConfiguration()  // Defaults may not be appropriate
```

### Context Control
```swift
// ✅ Explicit context enabling
TrackerConfiguration()
    .sessionContext(true)
    .platformContext(true)
    .applicationContext(false)  // Opt-out

// ❌ Assume all contexts enabled
TrackerConfiguration()
    .trackAllContexts(true)  // Too broad
```

### Platform Context Properties
```swift
// ✅ Select specific properties
TrackerConfiguration()
    .platformContextProperties([
        .osType, .osVersion, .deviceModel
    ])

// ❌ Track everything
.platformContextProperties(nil)  // May include PII
```

## NetworkConfiguration

### Endpoint Setup
```swift
// ✅ Secure endpoint with method
NetworkConfiguration(endpoint: "https://collector.com")
    .method(.post)
    .customPostPath("/com.snowplow/tp2")

// ❌ Insecure configuration
NetworkConfiguration(endpoint: "http://collector.com")
    .method(.get)  // GET has size limits
```

### Custom Headers
```swift
// ✅ Add authentication headers
NetworkConfiguration(endpoint: url)
    .requestHeaders(["Authorization": "Bearer token"])

// ❌ Headers in wrong config
TrackerConfiguration()
    .headers(["Auth": "token"])  // Not supported
```

## EmitterConfiguration

### Buffer Management
```swift
// ✅ Configure batching
EmitterConfiguration()
    .bufferOption(.single)  // Real-time
    // or
    .bufferOption(.defaultGroup)  // Batch of 25

// ❌ Arbitrary buffer sizes
.bufferOption(.custom(1000))  // Too large
```

### Request Callbacks
```swift
// ✅ Handle emit results
EmitterConfiguration()
    .requestCallback { count, success in
        if !success {
            logError("Failed to send \(count) events")
        }
    }

// ❌ Ignore failures
EmitterConfiguration()  // Silent failures
```

### Thread Pool Control
```swift
// ✅ Appropriate thread count
EmitterConfiguration()
    .threadPoolSize(2)  // Mobile-friendly

// ❌ Too many threads
.threadPoolSize(10)  // Battery drain
```

## SessionConfiguration

### Timeout Settings
```swift
// ✅ Reasonable timeouts
SessionConfiguration(
    foregroundTimeout: Measurement(value: 30, unit: .minutes),
    backgroundTimeout: Measurement(value: 5, unit: .minutes)
)

// ❌ Too short timeouts
SessionConfiguration(
    foregroundTimeout: Measurement(value: 10, unit: .seconds)
)  // Too many sessions
```

### Session Callbacks
```swift
// ✅ Track session lifecycle
SessionConfiguration(
    onSessionStateUpdate: { state in
        analytics.track("session_update", state)
    }
)

// ❌ Heavy operations in callback
onSessionStateUpdate: { state in
    saveToDatabase(state)  // Blocks tracking
}
```

## SubjectConfiguration

### User Properties
```swift
// ✅ Set user information
SubjectConfiguration()
    .userId("user-123")
    .networkUserId(UUID())
    .domainUserId("domain-user")

// ❌ PII in wrong fields
SubjectConfiguration()
    .userId("john@example.com")  // Use hashed ID
```

### Screen Dimensions
```swift
// ✅ Platform-specific dimensions
#if os(iOS)
SubjectConfiguration()
    .screenResolution(UIScreen.main.bounds.size)
#endif

// ❌ Hardcoded dimensions
.screenResolution(CGSize(width: 375, height: 812))
```

## GDPRConfiguration

### Privacy Basis
```swift
// ✅ Clear legal basis
GDPRConfiguration(
    basis: .consent,
    documentId: "privacy-policy-v2",
    documentVersion: "2.0",
    documentDescription: "User consent for analytics"
)

// ❌ Vague configuration
GDPRConfiguration(
    basis: .consent,
    documentId: "doc1"
)  // Insufficient detail
```

## GlobalContextsConfiguration

### Context Generators
```swift
// ✅ Dynamic context generation
GlobalContextsConfiguration()
    .contextGenerators([
        GlobalContext(generator: { event in
            return [createUserContext()]
        })
    ])

// ❌ Static contexts
.contextGenerators([
    GlobalContext(staticContexts: [context])
])  // Won't update
```

### Schema Rules
```swift
// ✅ Apply to specific events
GlobalContext(
    tag: "user_context",
    generator: { _ in [userContext] },
    ruleset: SchemaRuleset(
        allowed: ["iglu:com.example/purchase/*"]
    )
)

// ❌ Apply to all events
GlobalContext(generator: { _ in [heavyContext] })
// Performance impact
```

## Remote Configuration

### Configuration Fetching
```swift
// ✅ Setup with fallback
Snowplow.setup(
    remoteConfiguration: RemoteConfiguration(
        endpoint: "https://config.example.com",
        method: .get
    ),
    defaultConfiguration: [
        ConfigurationBundle(namespace: "default", ...)
    ]
)

// ❌ No fallback
Snowplow.setup(
    remoteConfiguration: RemoteConfiguration(...)
)  // Fails if network unavailable
```

## Configuration State

### Serialization
```swift
// ✅ Implement SerializableConfiguration
class CustomConfiguration: SerializableConfiguration {
    func toJSON() -> [String: Any] {
        return ["key": value]
    }
}

// ❌ Manual serialization
let json = ["config": config.description]
```

### Configuration Updates
```swift
// ✅ Update through controller
trackerController.emitter.bufferOption = .single

// ❌ Direct mutation
tracker.emitterConfiguration.bufferOption = .single
// May not take effect
```

## Plugin Configuration

### Custom Plugins
```swift
// ✅ Implement plugin protocol
class CustomPlugin: PluginConfiguration {
    func configure(tracker: TrackerController) {
        // Setup logic
    }
}

// ❌ Side effects in init
class CustomPlugin: PluginConfiguration {
    init() {
        startBackgroundTask()  // Too early
    }
}
```

## Common Configuration Pitfalls

### 1. Configuration Timing
```swift
// ❌ Configure after tracking
let tracker = createTracker()
tracker.track(event)
tracker.sessionContext = true  // Too late

// ✅ Configure before use
let tracker = createTracker {
    TrackerConfiguration().sessionContext(true)
}
```

### 2. Conflicting Configurations
```swift
// ❌ Multiple network configs
let configs = [
    NetworkConfiguration(endpoint: "url1"),
    NetworkConfiguration(endpoint: "url2")
]  // Which one wins?

// ✅ Single network config
let configs = [
    NetworkConfiguration(endpoint: "url"),
    TrackerConfiguration()
]
```

### 3. Missing Validation
```swift
// ❌ Invalid configuration
NetworkConfiguration(endpoint: "not a url")

// ✅ Validate configuration
guard let url = URL(string: endpoint) else {
    throw ConfigurationError.invalidEndpoint
}
```

## Quick Reference

### Configuration Checklist
- [ ] Set unique namespace
- [ ] Configure network endpoint (HTTPS)
- [ ] Set appropriate buffer option
- [ ] Configure session timeouts
- [ ] Enable required contexts
- [ ] Set user properties if available
- [ ] Configure GDPR if applicable
- [ ] Add global contexts if needed
- [ ] Set log level for debugging
- [ ] Configure platform-specific settings