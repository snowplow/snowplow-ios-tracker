//
//  SPTrackerController.h
//  Snowplow
//
//  Created by Alex Benini on 02/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTrackerControlling.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerController)
@interface SPTrackerController : NSObject <SPTrackerControlling>

- (instancetype)initWithTracker:(SPTracker *)tracker;

@end

NS_ASSUME_NONNULL_END
