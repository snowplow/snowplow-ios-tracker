//
//  SPServiceProviderProtocol.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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

@end

NS_ASSUME_NONNULL_END
