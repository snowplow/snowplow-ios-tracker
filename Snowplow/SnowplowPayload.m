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
    
    // We do this only for JSON error checking
    id object = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    
    if (error) {
        NSLog(@"addJsonToPayload: error: %@", error.localizedDescription);
        return;
    }
    
    // Checks if it conforms to NSDictionary type
    if([object isKindOfClass:[NSDictionary class]]) {
        NSString *result = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
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
            [self addValueToPayload:encodedString withKey:typeEncoded];
        } else {
            [self addValueToPayload:result withKey:typeNotEncoded];
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

- (NSDictionary *) getPayload {
    return self.payload;
}

@end
