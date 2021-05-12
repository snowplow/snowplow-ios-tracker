//
//  SPJSONSerialization.h
//  Snowplow
//
//  Created by Alex Benini on 04/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPJSONSerialization : NSObject

+ (nullable NSData *)serializeDictionary:(nonnull NSDictionary *)dictionary;
+ (nullable NSDictionary *)deserializeData:(nonnull NSData *)data;

@end

NS_ASSUME_NONNULL_END
