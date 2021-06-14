//
//  SPGlobalContextsControllerImpl.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.
//
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPGlobalContextsControllerImpl.h"
#import "SPTracker.h"


@implementation SPGlobalContextsControllerImpl

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

- (NSArray<NSString *> *)tags {
    return [self.tracker globalContextTags];
}

// MARK: - Private methods

- (SPTracker *)tracker {
    return self.serviceProvider.tracker;
}

@end
