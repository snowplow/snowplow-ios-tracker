//
//  SPController.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPServiceProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPController : NSObject

@property (nonatomic, nonnull, readonly) id<SPServiceProviderProtocol> serviceProvider;

- (instancetype)initWithServiceProvider:(id<SPServiceProviderProtocol>)serviceProvider;

@end

NS_ASSUME_NONNULL_END
