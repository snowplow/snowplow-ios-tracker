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

/// A message dispatched from a server-sent event stream.
struct EventStreamMessage: Equatable {
    /// The `event` field, `message` when the server didn't set one.
    let event: String
    /// The `data` fields joined by newlines.
    let data: String
}

/// Incremental parser for the `text/event-stream` format (server-sent events).
///
/// Bytes arrive in arbitrary chunks, so lines are buffered until their end of line is seen.
/// Lines may end with LF, CR or CRLF; comment lines (starting with `:`, such as heartbeats) are ignored;
/// `id` and `retry` fields are ignored.
class EventStreamParser {
    private static let lineFeed: UInt8 = 0x0A
    private static let carriageReturn: UInt8 = 0x0D

    private var line = Data()
    private var lastByteWasCarriageReturn = false
    private var eventType = ""
    private var dataLines: [String] = []

    /// Parses the next chunk of the stream.
    /// - Returns: The messages completed by this chunk, in order.
    func append(_ chunk: Data) -> [EventStreamMessage] {
        var messages: [EventStreamMessage] = []
        for byte in chunk {
            if byte == EventStreamParser.lineFeed && lastByteWasCarriageReturn {
                // second half of a CRLF line ending
                lastByteWasCarriageReturn = false
                continue
            }
            lastByteWasCarriageReturn = byte == EventStreamParser.carriageReturn
            if byte == EventStreamParser.lineFeed || byte == EventStreamParser.carriageReturn {
                if let message = processLine(String(decoding: line, as: UTF8.self)) {
                    messages.append(message)
                }
                line.removeAll(keepingCapacity: true)
            } else {
                line.append(byte)
            }
        }
        return messages
    }

    /// Discards any partially received message, e.g. before reading a new connection.
    func reset() {
        line.removeAll()
        lastByteWasCarriageReturn = false
        eventType = ""
        dataLines.removeAll()
    }

    private func processLine(_ line: String) -> EventStreamMessage? {
        if line.isEmpty {
            // a blank line dispatches the buffered event
            defer {
                eventType = ""
                dataLines.removeAll()
            }
            guard !dataLines.isEmpty else { return nil }
            return EventStreamMessage(event: eventType.isEmpty ? "message" : eventType,
                                      data: dataLines.joined(separator: "\n"))
        }
        if line.hasPrefix(":") {
            return nil
        }

        let field: Substring
        var value: Substring
        if let colon = line.firstIndex(of: ":") {
            field = line[..<colon]
            value = line[line.index(after: colon)...]
            if value.hasPrefix(" ") {
                value = value.dropFirst()
            }
        } else {
            field = Substring(line)
            value = ""
        }

        switch field {
        case "data":
            dataLines.append(String(value))
        case "event":
            eventType = String(value)
        default:
            break
        }
        return nil
    }
}
