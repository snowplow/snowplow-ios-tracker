//
//  SPConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 27/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snowplow.h"

#ifndef SP_STR_PROP
    #define SP_STR_PROP(prop) NSStringFromSelector(@selector(prop))
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Configuration)
@interface SPConfiguration : NSObject <NSCopying, NSCoding>

@end

NS_ASSUME_NONNULL_END
