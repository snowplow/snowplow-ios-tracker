//
//  SnowplowRequest.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-08.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import "SnowplowRequest.h"

@implementation SnowplowRequest

- (id)initWithURLRequest:(NSURL *)url withHTTPMethod:(NSString* )method {
    self = [super init];
    if(self) {
        self.urlRequest = [[NSMutableURLRequest alloc] init];
        self.url = url;
        self.httpMethod = method;
    }
    return self;
}

- (void)dealloc {
    self.url = nil;
    self.connection = nil;
    self.response = nil;
    self.urlRequest = nil;
    self.error = nil;
}

- (void)sendRequest:(NSDictionary *)data {
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];

    NSLog(@"postData: %@", @[[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]]);
    NSLog(@"url: %@", self.url);
    [self.urlRequest setURL:self.url];
    [self.urlRequest setHTTPMethod:self.httpMethod];
    [self.urlRequest setHTTPBody:postData];
    [self.urlRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];

    self.connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
    
    [self.connection cancel];

}

@end
