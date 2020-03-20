//
//  SPTrackerEvent.h
//  Snowplow
//
//  Created by Alex Benini on 13/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPTrackerEvent : NSObject

@property (nonatomic) NSDictionary<NSString *, NSObject *> *payload;
@property (nonatomic) NSString *schema;
@property (nonatomic) NSString *eventName;
@property (nonatomic) NSUUID *eventId;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) NSMutableArray<SPSelfDescribingJson *> *contexts;

@property (nonatomic) BOOL isBuiltIn;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

+ (instancetype)trackerEventWithSelfDescribing:(SPSelfDescribing *)event;
+ (instancetype)trackerEventWithBuiltIn:(SPBuiltIn *)event;

@end

NS_ASSUME_NONNULL_END
