//
//  SPServiceProviderProtocol.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

protocol ServiceProviderProtocol: AnyObject {
    var namespace: String { get }
    var isTrackerInitialized: Bool { get }
    var tracker: Tracker { get }
    var emitter: Emitter { get }
    var subject: Subject { get }
    var trackerController: TrackerControllerImpl { get }
    var emitterController: EmitterControllerImpl { get }
    var networkController: NetworkControllerImpl { get }
    var gdprController: GDPRControllerImpl { get }
    var globalContextsController: GlobalContextsControllerImpl { get }
    var subjectController: SubjectControllerImpl { get }
    var sessionController: SessionControllerImpl { get }
    var networkConfigurationUpdate: NetworkConfigurationUpdate { get }
    var trackerConfigurationUpdate: TrackerConfigurationUpdate { get }
    var emitterConfigurationUpdate: EmitterConfigurationUpdate { get }
    var subjectConfigurationUpdate: SubjectConfigurationUpdate { get }
    var sessionConfigurationUpdate: SessionConfigurationUpdate { get }
    var gdprConfigurationUpdate: GDPRConfigurationUpdate { get }
}
