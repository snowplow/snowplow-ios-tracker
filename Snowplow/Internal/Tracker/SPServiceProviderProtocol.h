//
//  SPServiceProviderProtocol.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPSubject;
@class SPEmitter;
@class SPTracker;
@class SPTrackerControllerImpl;
@class SPEmitterControllerImpl;
@class SPNetworkControllerImpl;
@class SPGDPRControllerImpl;
@class SPGlobalContextsControllerImpl;
@class SPSubjectControllerImpl;
@class SPSessionControllerImpl;

@class SPNetworkConfigurationUpdate;
@class SPTrackerConfigurationUpdate;
@class SPEmitterConfigurationUpdate;
@class SPSubjectConfigurationUpdate;
@class SPSessionConfigurationUpdate;
@class SPGDPRConfigurationUpdate;

NS_ASSUME_NONNULL_BEGIN

@protocol SPServiceProviderProtocol

@property (nonatomic, nonnull, readonly) NSString *namespace;

- (SPTracker *)tracker;
- (SPEmitter *)emitter;
- (SPSubject *)subject;

- (SPTrackerControllerImpl *)trackerController;
- (SPEmitterControllerImpl *)emitterController;
- (SPNetworkControllerImpl *)networkController;
- (SPGDPRControllerImpl *)gdprController;
- (SPGlobalContextsControllerImpl *)globalContextsController;
- (SPSubjectControllerImpl *)subjectController;
- (SPSessionControllerImpl *)sessionController;

- (SPNetworkConfigurationUpdate *)networkConfigurationUpdate;
- (SPTrackerConfigurationUpdate *)trackerConfigurationUpdate;
- (SPEmitterConfigurationUpdate *)emitterConfigurationUpdate;
- (SPSubjectConfigurationUpdate *)subjectConfigurationUpdate;
- (SPSessionConfigurationUpdate *)sessionConfigurationUpdate;
- (SPGDPRConfigurationUpdate *)gdprConfigurationUpdate;

@end

NS_ASSUME_NONNULL_END
