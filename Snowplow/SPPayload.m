//
//  SPPayload.m
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPPayload.h"

@implementation SPPayload {
    NSMutableDictionary * _payload;
}

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
        _payload = [[NSMutableDictionary alloc] init];
        [self addDictionaryToPayload:dict];
    }
    return self;
}

- (void) addValueToPayload:(NSString *)value forKey:(NSString *)key {
    if ([value length] == 0) {
        if ([_payload valueForKey:key] != nil) {
            [_payload removeObjectForKey:key];
        }
        return;
    }
    [_payload setObject:value forKey:key];
}

- (void) addDictionaryToPayload:(NSDictionary *)dict {
    if (dict != nil) {
        for (NSString * key in dict) {
            id value = [dict objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [self addValueToPayload:(NSString *)value forKey:key];
            }
        }
    }
}

- (void) addJsonToPayload:(NSData *)json
            base64Encoded:(Boolean)encode
          typeWhenEncoded:(NSString *)typeEncoded
       typeWhenNotEncoded:(NSString *)typeNotEncoded {
    NSError *error = nil;
    NSDictionary *object = nil;
    
    @try {
        object = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    }
    @catch (NSException *exception) {
        SnowplowDLog(@"SPLog: addJsonToPayload error, %@", error.localizedDescription);
        return;
    }
    
    // Checks if it conforms to NSDictionary type
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSString *encodedString = nil;
        if (encode) {
            encodedString = [json base64EncodedStringWithOptions:0];

            // We need URL safe with no padding. Since there is no built-in way to do this, we transform
            // the encoded payload to make it URL safe by replacing chars that are different in the URL-safe
            // alphabet. Namely, 62 is - instead of +, and 63 _ instead of /.
            // See: https://tools.ietf.org/html/rfc4648#section-5
            encodedString = [[encodedString stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
                             stringByReplacingOccurrencesOfString:@"+" withString:@"-"];

            // There is also no padding since the length is implicitly known.
            encodedString = [encodedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
            
            [self addValueToPayload:encodedString forKey:typeEncoded];
        } else {
            [self addValueToPayload:[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] forKey:typeNotEncoded];
        }
    }
}

- (void) addJsonStringToPayload:(NSString *)json
                  base64Encoded:(Boolean)encode
                typeWhenEncoded:(NSString *)typeEncoded
             typeWhenNotEncoded:(NSString *)typeNotEncoded {
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

- (NSDictionary *) getAsDictionary {
    return _payload;
}

- (NSString *) description {
    return [[self getAsDictionary] description];
}

@end
