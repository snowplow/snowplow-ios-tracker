//
//  SnowplowPayload.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.
//
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SnowplowPayload.h"

@implementation SnowplowPayload

- (id) init {
    self = [super init];
    if(self) {
        _payload = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id) initWithNSDictionary:(NSDictionary *) dict {
    self = [super init];
    if(self) {
        _payload = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    return self;
}

+ (instancetype) payloadWithDictionary:(NSDictionary *) dict {
    return [[self alloc] initWithDictionary:dict];
}

- (void) addValueToPayload:(id)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    [self.payload setObject:value forKey:key];
}

- (void) addDictionaryToPayload:(NSDictionary *)dict {
    if (dict == nil) {
        return;
    }
    [self.payload addEntriesFromDictionary:dict];
}

- (void) addJsonToPayload:(NSData *)json
            base64Encoded:(Boolean)encode
          typeWhenEncoded:(NSString *)typeEncoded
       typeWhenNotEncoded:(NSString *)typeNotEncoded {
    NSError *error = nil;
    
    // We do this only for JSON error checking
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    
    if (error) {
        NSLog(@"addJsonToPayload: error: %@", error.localizedDescription);
        return;
    }
    
    // Checks if it conforms to NSDictionary type
    if([object isKindOfClass:[NSDictionary class]]) {
        NSString *encodedString = nil;
        if(encode) {
            
            // We want to use the iOS 7 encoder if it's 7+ so we check if it's available
            if([NSData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                encodedString = [json base64EncodedStringWithOptions:0];
                NSLog(@"Using iOS 7 encoding: %@", encodedString);
            } else {
                // Officially deprecated in iOS 7, but works in all versions including 7
                encodedString = [json base64Encoding];
                NSLog(@"Using 3PD encoding: %@", encodedString);
            }
            [self addValueToPayload:encodedString forKey:typeEncoded];
        } else {
            [self addValueToPayload:object forKey:typeNotEncoded];
        }
    } // else handle a bad name-value pair even though it passes JSONSerialization?
}

- (void) addJsonStringToPayload:(NSString *)json
                  base64Encoded:(Boolean)encode
                typeWhenEncoded:(NSString *)typeEncoded
             typeWhenNotEncoded:(NSString *)typeNotEncoded {
    
    // This method is added just to make it easier to accept JSON as a string
    // Can be removed later if it's unused.
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];

    [self addJsonToPayload:data
             base64Encoded:encode
           typeWhenEncoded:typeEncoded
        typeWhenNotEncoded:typeNotEncoded];
    
}

- (void) addDictionaryToPayload:(NSDictionary *)json
                      base64Encoded:(Boolean)encode
                    typeWhenEncoded:(NSString *)typeEncoded
                 typeWhenNotEncoded:(NSString *)typeNotEncoded {
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    
    [self addJsonToPayload:data
             base64Encoded:encode
           typeWhenEncoded:typeEncoded
        typeWhenNotEncoded:typeNotEncoded];
}

- (NSDictionary *) getPayload {
    return self.payload;
}

@end
