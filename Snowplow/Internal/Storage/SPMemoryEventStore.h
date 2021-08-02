//
//  SPMemoryEventStore.h
//  Snowplow
//
//  Created by Alex Benini on 02/08/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventStore.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MemoryEventStore)
@interface SPMemoryEventStore : NSObject <SPEventStore>

@end

NS_ASSUME_NONNULL_END
