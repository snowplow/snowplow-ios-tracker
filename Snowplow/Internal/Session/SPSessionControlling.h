//
//  SPSessionControlling.h
//  Snowplow
//
//  Created by Alex Benini on 01/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSessionConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionControlling)
@protocol SPSessionControlling <SPSessionConfigurationProtocol>

@property (readonly) NSInteger sessionIndex;
@property (readonly) NSString *sessionId;
@property (readonly) NSString *userId;

@property (readonly) BOOL isInBackground;
@property (readonly) NSInteger backgroundIndex;
@property (readonly) NSInteger foregroundIndex;

- (void)pause;
- (void)resume;
- (void)startNewSession;

@end

NS_ASSUME_NONNULL_END
