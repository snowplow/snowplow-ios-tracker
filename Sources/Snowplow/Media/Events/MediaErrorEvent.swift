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

import Foundation

/**
 Media player event tracked when the resource could not be loaded due to an error.
 */
@objc(SPMediaErrorEvent)
public class MediaErrorEvent: SelfDescribingAbstract {
    
    /// Error-identifying code for the playback issue. E.g. E522
    @objc
    public var errorCode: String?
    
    /// Name for the type of error that occurred in the playback. E.g. forbidden
    @objc
    public var errorName: String?
    
    /// Longer description for the error that occurred in the playback.
    @objc
    public var errorDescription: String?
    
    override var schema: String {
        return MediaSchemata.eventSchema("error")
    }
    
    override var payload: [String : Any] {
        var data: [String : Any] = [:]
        if let errorCode = errorCode { data["errorCode"] = errorCode }
        if let errorName = errorName { data["errorName"] = errorName }
        if let errorDescription = errorDescription { data["errorDescription"] = errorDescription }
        return data
    }
    
    /// - Parameter errorCode: Error-identifying code for the playback issue. E.g. E522
    /// - Parameter errorName: Name for the type of error that occurred in the playback. E.g. forbidden
    /// - Parameter errorDescription: Longer description for the error that occurred in the playback.
    @objc
    public init(errorCode: String? = nil, errorName: String? = nil, errorDescription: String? = nil) {
        self.errorCode = errorCode
        self.errorName = errorName
        self.errorDescription = errorDescription
    }
    
    /// Error-identifying code for the playback issue. E.g. E522
    @objc
    public func errorCode(_ errorCode: String?) -> Self {
        self.errorCode = errorCode
        return self
    }
    
    /// Name for the type of error that occurred in the playback. E.g. forbidden
    @objc
    public func errorName(_ errorName: String?) -> Self {
        self.errorName = errorName
        return self
    }
    
    /// Longer description for the error that occurred in the playback.
    @objc
    public func errorDescription(_ errorDescription: String?) -> Self {
        self.errorDescription = errorDescription
        return self
    }
}
