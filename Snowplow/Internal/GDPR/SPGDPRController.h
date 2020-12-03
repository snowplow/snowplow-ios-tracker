//
//  SPGDPRController.h
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGDPRControlling.h"
#import "SPTracker.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GDPRController)
@interface SPGDPRController : NSObject <SPGDPRControlling>

- (instancetype)initWithTracker:(SPTracker *)tracker;

@end

NS_ASSUME_NONNULL_END
