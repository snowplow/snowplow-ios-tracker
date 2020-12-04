//
//  SPGlobalContextsController.h
//  Snowplow
//
//  Created by Alex Benini on 04/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGlobalContextsControlling.h"
#import "SPTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPGlobalContextsController : NSObject <SPGlobalContextsControlling>

- (instancetype)initWithTracker:(SPTracker *)tracker;

@end

NS_ASSUME_NONNULL_END
