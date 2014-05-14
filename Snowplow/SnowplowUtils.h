//
//  SnowplowUtils.h
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-13.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIScreen.h>

@interface SnowplowUtils : NSObject

- (NSString *) getTimezone;

- (NSString *) getLanguage;

- (NSString *) getPlatform;

- (NSString *) getEventId;

// Returns an NSDictionary with 'width' and 'height'
- (NSDictionary *) getResolution;

// Returns an NSDictionary with 'width' and 'height'
- (NSDictionary *) getViewPort;

@end
