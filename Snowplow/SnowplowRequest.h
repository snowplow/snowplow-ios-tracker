//
//  SnowplowRequest.h
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-08.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnowplowRequest : NSObject

@property (nonatomic) NSURL *url;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSHTTPURLResponse *response;
@property (nonatomic) id responseJSON;
@property (nonatomic) NSMutableURLRequest *urlRequest;
@property (nonatomic) NSError *error;

@end
