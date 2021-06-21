//
//  SPMockEventStore.h
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 31/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventStore.h"
#import "SPPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPMockEventStore : NSObject <SPEventStore>

@property (atomic) NSMutableDictionary<NSNumber *, SPPayload *> *db;
@property (atomic) long lastInsertedRow;

@end

NS_ASSUME_NONNULL_END
