//
//  SPSubjectConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 27/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPSubjectConfiguration.h"

@implementation SPSubjectConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.screenResolution = CGSizeZero;
        self.screenViewPort = CGSizeZero;
        self.colorDepth = 0;
    }
    return self;
}

@end
