//
//  SPGlobalContextsController.m
//  Snowplow
//
//  Created by Alex Benini on 04/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPGlobalContextsController.h"

@interface SPGlobalContextsController ()

@property (nonatomic) SPTracker *tracker;

@end

@implementation SPGlobalContextsController

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
    }
    return self;
}

- (void)setContextGenerators:(NSMutableDictionary<NSString *,SPGlobalContext *> *)contextGenerators {
    [self.tracker setGlobalContextGenerators:contextGenerators];
}

- (NSMutableDictionary<NSString *,SPGlobalContext *> *)contextGenerators {
    return [self.tracker globalContextGenerators];
}

- (BOOL)addWithTag:(nonnull NSString *)tag contextGenerator:(nonnull SPGlobalContext *)generator {
    return [self.tracker addGlobalContext:generator tag:tag];
}

- (nullable SPGlobalContext *)removeWithTag:(nonnull NSString *)tag {
    return [self.tracker removeGlobalContext:tag];
}

@end
