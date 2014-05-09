//
//  SnowplowPayload.h
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-08.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Base64.h"

@interface SnowplowPayload : NSObject

@property (nonatomic, strong) NSMutableDictionary *payload;

- (id) init;

- (id) initWithNSDictionary:(NSDictionary *)dict;

- (void) addToPayload:(NSString *)value :(NSString *)key;

- (void) addDictionaryToPayload:(NSDictionary *)dict;

- (NSError *) addJsonToPayload: (NSData *)json
                 base64Encoded: (Boolean)encode
               typeWhenEncoded: (NSString *)typeEncoded
            typeWhenNotEncoded: (NSString *)typeNotEncoded;

- (NSDictionary *) getPayload;

@end
