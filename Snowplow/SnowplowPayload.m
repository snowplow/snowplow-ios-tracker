//
//  SnowplowPayload.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-08.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import "SnowplowPayload.h"

@implementation SnowplowPayload

- (id) init {
    self = [super init];
    if(self) {
        self.payload = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id) initWithNSDictionary:(NSDictionary *) dict {
    self = [super init];
    if(self) {
        self.payload = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    return self;
}

- (void) addValueToPayload:(NSString *)value withKey:(NSString *)key {
    [self.payload setObject:value forKey:key];
}

- (void) addDictionaryToPayload:(NSDictionary *)dict {
    [self.payload addEntriesFromDictionary:dict];
}

- (void) addJsonToPayload:(NSData *)json
                 base64Encoded:(Boolean)encode
               typeWhenEncoded:(NSString *)typeEncoded
            typeWhenNotEncoded:(NSString *)typeNotEncoded {
    NSError *error = nil;
    
    id object = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    
    if (error) {
        NSLog(@"addJsonToPayload: error: %@", error.localizedDescription);
        return;
    }
    
    if([object isKindOfClass:[NSDictionary class]]) {
        NSString *result = object;
        NSString *encodedString = nil;
        if(encode) {
            
            // We want to use the iOS 7 encoder if it's 7+ so we check if it's available
            if([NSData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                NSData *plainData = [result dataUsingEncoding:NSUTF8StringEncoding];
                encodedString = [plainData base64EncodedStringWithOptions:0];
                
                NSLog(@"Using iOS 7 encoding: %@", encodedString);
            } else {
                NSData *plainData = [result dataUsingEncoding:NSUTF8StringEncoding];
                encodedString = [plainData base64EncodedString];
                
                NSLog(@"Using 3PD encoding: %@", encodedString);
            }
            [self addValueToPayload:encodedString withKey:typeEncoded];
        } else {
            [self addValueToPayload:result withKey:typeNotEncoded];
        }
    } // else handle a bad name-value pair even though it passes JSONSerialization?
}

- (NSDictionary *) getPayload {
    return self.payload;
}

@end
