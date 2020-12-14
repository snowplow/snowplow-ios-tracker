//
//  SPServiceProvider.h
//  Snowplow
//
//  Created by Alex Benini on 11/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSubject.h"
#import "SPEmitter.h"
#import "SPTracker.h"
#import "SPTrackerControlling.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPServiceProvider : NSObject

@property (nonatomic, nullable) SPEmitter *emitter;
@property (nonatomic, nullable) SPSubject *subject;
@property (nonatomic, nullable) SPTracker *tracker;

@property (nonatomic, nullable) id<SPTrackerControlling> trackerController;

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration;

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations;

- (instancetype)initWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations;

@end

NS_ASSUME_NONNULL_END
