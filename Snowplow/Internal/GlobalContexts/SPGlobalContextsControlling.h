//
//  SPGlobalContextsControlling.h
//  Snowplow
//
//  Created by Alex Benini on 04/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGlobalContextsConfiguration.h"
#import "SPGlobalContext.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlobalContextsControlling)
@protocol SPGlobalContextsControlling <SPGlobalContextsConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
