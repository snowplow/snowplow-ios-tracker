//
//  Snowplow.h
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-08.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnowplowRequest.h"

@interface Snowplow : NSObject

@property (nonatomic, strong) SnowplowRequest *requestHandler;

- (id) initWithURLString:(NSString *) url;

- (void) sendEvent:(NSDictionary *) data;

@end
