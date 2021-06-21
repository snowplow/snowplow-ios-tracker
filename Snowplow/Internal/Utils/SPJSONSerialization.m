//
//  SPJSONSerialization.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
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
