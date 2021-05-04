//
//  SPJSONSerialization.m
//  Snowplow
//
//  Created by Alex Benini on 04/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPJSONSerialization.h"
#import "SPLogger.h"

@implementation SPJSONSerialization

+ (NSData *)serializeDictionary:(NSDictionary *)dictionary {
    NSError *error = nil;
    NSData *data;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    }
    @catch (NSException *exception) {
        SPLogError(@"Dictionary to Data Exception, %@", exception.name);
        return nil;
    }
    if (error) {
        SPLogError(@"Dictionary to Data Error, %@", error);
        return nil;
    }
    return data;
}

+ (NSDictionary *)deserializeData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *dictionary;
    @try {
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    }
    @catch (NSException *exception) {
        SPLogError(@"Data to Dictionary Exception, %@", exception.name);
        return nil;
    }
    if (error) {
        SPLogError(@"Data to Dictionary Error, %@", error);
        return nil;
    }
    if (![dictionary isKindOfClass:NSDictionary.class]) {
        SPLogError(@"Serialized json isn't a Dictionary type");
        return nil;
    }
    return dictionary;
}

@end
