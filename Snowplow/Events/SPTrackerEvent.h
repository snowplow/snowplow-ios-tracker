//
//  SPTrackerEvent.h
//  Snowplow
//
//  Created by Alex Benini on 13/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPPayload;
@class SPEvent;

NS_ASSUME_NONNULL_BEGIN

@interface SPTrackerEvent : NSObject

@property (nonatomic) SPPayload *payload;
@property (nonatomic) NSUUID *eventId;
@property (nonatomic) NSTimeInterval timestamp;
//@property (nonatomic) NSArray<SPContext *> contexts;
@property (nonatomic) BOOL isServiceEvent;

- (instancetype)initWithEvent:(SPEvent *)event;

@end

NS_ASSUME_NONNULL_END
