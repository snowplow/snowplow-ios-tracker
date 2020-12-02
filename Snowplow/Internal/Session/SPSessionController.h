//
//  SPSessionController.h
//  Snowplow
//
//  Created by Alex Benini on 01/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSessionControlling.h"
#import "SPSession.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionController)
@interface SPSessionController : NSObject <SPSessionControlling>

- (instancetype)initWithSession:(SPSession *)sessionManager;

@end

NS_ASSUME_NONNULL_END
