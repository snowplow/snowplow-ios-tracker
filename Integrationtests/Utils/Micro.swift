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
import XCTest

class Micro {
    
    static let timeout = 10.0
    static let retryDelay = 0.5
    static let maxNumberOfRetries = 19
#if os(macOS)
    static let endpoint = "http://localhost:9090"
#else
    static let endpoint = "http://0.0.0.0:9090"
#endif
    
    class func reset() -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Reset Micro")
        let url = URLRequest(url: URL(string: "\(endpoint)/micro/reset")!)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                XCTFail("Failed to reset Micro: \(error).")
            } else {
                _ = expectCounts(good: 0, bad: 0, expectation: expectation)
            }
        }
        task.resume()
        return expectation
    }
    
    class func expectCounts(
        good: Int = 0,
        bad: Int = 0,
        expectation: XCTestExpectation? = nil,
        numberOfRetries: Int = 0) -> XCTestExpectation {
        let expectation = expectation ?? XCTestExpectation(description: "Count of good and bad events")

        let url = URLRequest(url: URL(string: "\(endpoint)/micro/all")!)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                XCTFail("Failed to request Micro: \(error).")
            } else if let data = data,
                      let res = try? JSONDecoder().decode(AllResponse.self, from: data) {
                if res.good == good && res.bad == bad {
                    expectation.fulfill()
                } else if numberOfRetries < maxNumberOfRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                        _ = expectCounts(good: good,
                                     bad: bad,
                                     expectation: expectation,
                                     numberOfRetries: numberOfRetries + 1)
                    }
                } else {
                    XCTFail("Didn't find the expected event counts in Micro, actual: \(String(data: data, encoding: .utf8)!)")
                }
            } else {
                XCTFail("Failed to parse response from Micro")
            }
        }
        task.resume()
        
        return expectation
    }
    
    class func expectSelfDescribingEvent<T: Codable>(numberOfRetries: Int = 0,
                                                     completion: @escaping (T)->()) -> XCTestExpectation {
        return expectEvent() { (event: SelfDescribingResponse<T>) in
            completion(event.unstruct_event.data.data)
        }
    }
    
    class func expectPrimitiveEvent(numberOfRetries: Int = 0,
                                    completion: @escaping (PrimitiveResponse)->()) -> XCTestExpectation {
        return expectEvent() { (event: PrimitiveResponse) in
            completion(event)
        }
    }
    
    class func expectEventContext<T: Codable>(schema: String,
                                              completion: @escaping (T)->()) -> XCTestExpectation {
        return expectEvent(match: { (event: WithContextResponse<T>) in
            return event.contexts.data.filter({ $0.schema == schema }).compactMap({ $0.data }).first
        }, completion: completion)
    }

    private class func expectEvent<T: Codable>(expectation: XCTestExpectation? = nil,
                                               numberOfRetries: Int = 0,
                                               completion: @escaping (T)->()) -> XCTestExpectation {
        return expectEvent(expectation: expectation,
                           numberOfRetries: numberOfRetries,
                           match: { (decoded: T) in decoded },
                           completion: completion)
    }

    /// Poll `/micro/good` until some event in the response decodes into `Source` AND the
    /// provided `match` closure extracts a non-nil `Result` from it. This lets callers
    /// distinguish "no matching event yet" from "a matching event, but with wrong data",
    /// without failing the test on the first non-matching event.
    private class func expectEvent<Source: Codable, Result>(expectation: XCTestExpectation? = nil,
                                                            numberOfRetries: Int = 0,
                                                            match: @escaping (Source)->Result?,
                                                            completion: @escaping (Result)->()) -> XCTestExpectation {
        let expectation = expectation ?? XCTestExpectation(description: "Expected event")

        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            let url = URLRequest(url: URL(string: "\(endpoint)/micro/good")!)
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    XCTFail("Failed to request Micro: \(error).")
                } else if let data = data {
                    if let matched = findMatch(in: data, match: match) {
                        completion(matched)
                        expectation.fulfill()
                    } else if numberOfRetries < maxNumberOfRetries {
                        _ = expectEvent(expectation: expectation,
                                        numberOfRetries: numberOfRetries + 1,
                                        match: match,
                                        completion: completion)
                    } else {
                        XCTFail("Didn't find the expected event in Micro, actual: \(String(data: data, encoding: .utf8)!)")
                    }
                } else {
                    XCTFail("Failed to parse response from Micro")
                }
            }
            task.resume()
        }
        return expectation
    }

    private class func findMatch<Source: Codable, Result>(in data: Data,
                                                          match: (Source)->Result?) -> Result? {
        guard let array = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            return nil
        }
        let decoder = JSONDecoder()
        for element in array {
            guard let elementData = try? JSONSerialization.data(withJSONObject: element),
                  let decoded = try? decoder.decode(GoodResponse<Source>.self, from: elementData) else {
                continue
            }
            if let result = match(decoded.event) {
                return result
            }
        }
        return nil
    }
}

struct AllResponse: Codable {
    let good: Int
    let bad: Int
}

struct PrimitiveResponse: Codable {
    let se_category: String?
    let se_action: String?
    let se_label: String?
    let se_property: String?
    let se_value: Double?
    let page_url: String?
    let page_referrer: String?
}

struct SelfDescribingResponse<T: Codable>: Codable {
    let unstruct_event: UnstructEventResponse<T>
}

struct UnstructEventResponse<T: Codable>: Codable {
    let data: SelfDescribingDataResponse<T>
}

struct ContextEntityWrapper<T: Codable>: Decodable {
    let entity: T?
}

extension ContextEntityWrapper {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        entity = try? container.decode(T.self)
    }
}

struct ContextEntityResponse<T: Codable>: Codable {
    let schema: String
    let data: T?
}

extension ContextEntityResponse {
    private enum CodingKeys: String, CodingKey {
        case schema = "schema"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        schema = try container.decode(String.self, forKey: .schema)
        data = try? container.decode(T.self, forKey: .data)
    }
}

struct ContextsResponse<T: Codable>: Codable {
    let data: [ContextEntityResponse<T>]
}

struct WithContextResponse<T: Codable>: Codable {
    let contexts: ContextsResponse<T>
}

struct SelfDescribingDataResponse<T: Codable>: Codable {
    let data: T
}

struct GoodResponse<T: Codable>: Codable {
    let event: T
}
