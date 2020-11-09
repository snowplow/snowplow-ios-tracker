//
//  SPContextGenerator.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPGlobalContext.h"
#import "SPSchemaRuleset.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPGlobalContext ()

@property (nonatomic) SPGeneratorBlock generator;
@property (nonatomic, nullable) SPFilterBlock filter;

@end

NS_ASSUME_NONNULL_END

@implementation SPGlobalContext

- (instancetype)initWithContextGenerator:(id<SPContextGenerator>)generator {
    return [self initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return [generator generatorFromEvent:event];
    } filter:^BOOL(id<SPInspectableEvent> event) {
        return [generator filterFromEvent:event];
    }];
}

- (instancetype)initWithStaticContexts:(NSArray<SPSelfDescribingJson *> *)staticContexts {
    return [self initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return staticContexts;
    }];
}

- (instancetype)initWithGenerator:(SPGeneratorBlock)generator {
    return [self initWithGenerator:generator filter:nil];
}

- (instancetype)initWithStaticContexts:(NSArray<SPSelfDescribingJson *> *)staticContexts ruleset:(SPSchemaRuleset *)ruleset {
    return [self initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return staticContexts;
    } filter:ruleset.filterBlock];
}

- (instancetype)initWithGenerator:(SPGeneratorBlock)generator ruleset:(SPSchemaRuleset *)ruleset {
    return [self initWithGenerator:generator filter:ruleset.filterBlock];
}

- (instancetype)initWithStaticContexts:(NSArray<SPSelfDescribingJson *> *)staticContexts filter:(SPFilterBlock)filter {
    return [self initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return staticContexts;
    } filter:filter];
}

- (instancetype)initWithGenerator:(SPGeneratorBlock)generator filter:(SPFilterBlock)filter {
    if (self = [super init]) {
        self.generator = generator;
        self.filter = filter;
    }
    return self;
}

- (NSArray<SPSelfDescribingJson *> *)contextsFromEvent:(id<SPInspectableEvent>)event {
    if (!self.generator) {
        return nil;
    }
    if (self.filter && !self.filter(event)) {
        return nil;
    }
    return self.generator(event);
}

@end
