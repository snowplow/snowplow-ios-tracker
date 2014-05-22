//
//  NSDictionary+UrlEncoding.h
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-21.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString;

@end