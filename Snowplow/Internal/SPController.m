//
//  SPController.m
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPController.h"


@interface SPController ()

@property (nonatomic, nonnull) id<SPServiceProviderProtocol> serviceProvider;

@end

@implementation SPController

- (instancetype)initWithServiceProvider:(id<SPServiceProviderProtocol>)serviceProvider {
    if (self = [super init]) {
        self.serviceProvider = serviceProvider;
    }
    return self;
}

@end
