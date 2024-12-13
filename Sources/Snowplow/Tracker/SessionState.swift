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

@objc(SPSessionState)
public class SessionState: NSObject, State {
    @objc
    public private(set) var firstEventId: String?
    @objc
    public private(set) var firstEventTimestamp: String?
    @objc
    public private(set) var previousSessionId: String?
    @objc
    public private(set) var sessionId: String
    @objc
    public private(set) var sessionIndex = 0
    @objc
    public private(set) var storage: String
    @objc
    public private(set) var userId: String
    public private(set) var eventIndex: Int?
    public private(set) var lastUpdate: Int64?

    var sessionContext: [String : Any] {
        var dictionary: [String : Any] = [:]
        
        // required
        dictionary[kSPSessionUserId] = userId
        dictionary[kSPSessionId] = sessionId
        dictionary[kSPSessionIndex] = sessionIndex
        dictionary[kSPSessionStorage] = storage

        // optional
        if let previousSessionId = previousSessionId {
            dictionary[kSPSessionPreviousId] = previousSessionId
        }
        if let firstEventId = firstEventId {
            dictionary[kSPSessionFirstEventId] = firstEventId
        }
        if let firstEventTimestamp = firstEventTimestamp {
            dictionary[kSPSessionFirstEventTimestamp] = firstEventTimestamp
        }
        if let eventIndex = eventIndex {
            dictionary[kSPSessionEventIndex] = eventIndex
        }
        return dictionary
    }
    
    var dataToPersist: [String : Any] {
        var dictionary = sessionContext
        
        if let lastUpdate = lastUpdate {
            dictionary[ksSPSessionLastUpdate] = lastUpdate
        }
        
        return dictionary
    }

    init(
        firstEventId: String?,
        firstEventTimestamp: String?,
        currentSessionId: String,
        previousSessionId: String?,
        sessionIndex: Int,
        userId: String,
        storage: String,
        eventIndex: Int? = nil,
        lastUpdate: Int64? = nil
    ) {
        self.firstEventId = firstEventId
        self.firstEventTimestamp = firstEventTimestamp
        self.sessionId = currentSessionId
        self.previousSessionId = previousSessionId
        self.sessionIndex = sessionIndex
        self.userId = userId
        self.storage = storage
        self.eventIndex = eventIndex
        self.lastUpdate = lastUpdate
    }

    init?(storedState: [String : Any]) {
        guard let sessionId = storedState[kSPSessionId] as? String,
              let sessionIndex = storedState[kSPSessionIndex] as? Int,
              let userId = storedState[kSPSessionUserId] as? String else {
            return nil
        }
        
        self.sessionId = sessionId
        self.sessionIndex = sessionIndex
        self.userId = userId

        previousSessionId = storedState[kSPSessionPreviousId] as? String

        // The FirstEventId should be stored in legacy persisted sessions even
        // if it wasn't used. Anyway we provide a default value in order to be
        // defensive and exclude any possible issue with a missing value.
        firstEventId = storedState[kSPSessionFirstEventId] as? String ?? "00000000-0000-0000-0000-000000000000"
        firstEventTimestamp = storedState[kSPSessionFirstEventTimestamp] as? String

        storage = storedState[kSPSessionStorage] as? String ?? "LOCAL_STORAGE"
        
        eventIndex = storedState[kSPSessionEventIndex] as? Int
        
        lastUpdate = storedState[ksSPSessionLastUpdate] as? Int64
    }
    
    convenience init(eventId: String?, eventTimestamp: Int64) {
        self.init(
            firstEventId: eventId,
            firstEventTimestamp: Utilities.timestamp(toISOString: eventTimestamp),
            currentSessionId: Utilities.getUUIDString(),
            previousSessionId: nil,
            sessionIndex: 1,
            userId: Utilities.getUUIDString(),
            storage: "LOCAL_STORAGE",
            lastUpdate: Utilities.getTimestamp().int64Value
        )
    }
    
    func startNewSession(eventId: String?, eventTimestamp: Int64) {
        self.previousSessionId = self.sessionId
        self.sessionId = Utilities.getUUIDString()
        self.sessionIndex = self.sessionIndex + 1
        self.eventIndex = 0
        self.firstEventId = eventId
        self.firstEventTimestamp = Utilities.timestamp(toISOString: eventTimestamp)
        self.lastUpdate = Utilities.getTimestamp().int64Value
    }
    
    func updateForNextEvent(isSessionCheckerEnabled: Bool) {
        self.eventIndex = (self.eventIndex ?? 0) + 1
        if isSessionCheckerEnabled {
            self.lastUpdate = Utilities.getTimestamp().int64Value
        }
    }
}
