//
//  SPGlobalContextsConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 04/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPGlobalContext.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlobalContextsConfigurationProtocol)
@protocol SPGlobalContextsConfigurationProtocol

@property NSMutableDictionary<NSString *, SPGlobalContext *> *contextGenerators;

- (BOOL)addWithTag:(NSString *)tag contextGenerator:(SPGlobalContext *)generator NS_SWIFT_NAME(add(tag:contextGenerator:));
- (nullable SPGlobalContext *)removeWithTag:(NSString *)tag NS_SWIFT_NAME(remove(tag:));

@end

NS_SWIFT_NAME(GlobalContextsConfiguration)
@interface SPGlobalContextsConfiguration : SPConfiguration <SPGlobalContextsConfigurationProtocol>

SP_BUILDER_DECLARE(SP_ESCAPE(NSMutableDictionary<NSString *, SPGlobalContext *> *), contextGenerators)

@end

NS_ASSUME_NONNULL_END
