//
//  SPTrackerEvent.h
//  Snowplow
//
//  Created by Alex Benini on 13/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPTrackerEvent : NSObject

@property (nonatomic) NSDictionary *payload;
@property (nonatomic) NSString *schema;
@property (nonatomic) NSString *eventName;
@property (nonatomic) NSUUID *eventId;
@property (nonatomic) NSTimeInterval timestamp;
//@property (nonatomic) NSArray<SPContext *> *contexts;
@property (nonatomic) BOOL isServiceEvent;

- (instancetype)initWithSelfDescribingEvent:(SPSelfDescribing *)event;
- (instancetype)initWithBuiltInEvent:(SPBuiltIn *)event;

@end

NS_ASSUME_NONNULL_END
