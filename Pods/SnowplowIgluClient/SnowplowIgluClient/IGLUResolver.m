//
//  IGLUResolver.m
//  SnowplowIgluClient
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "IGLUConstants.h"
#import "IGLUResolver.h"
#import "IGLUUtilities.h"
#import "IGLUSchema.h"

@implementation IGLUResolver {
    NSString * _name;
    NSArray * _vendorPrefixes;
    NSString * _type;
    NSString * _uri;
    NSString * _path;
    NSNumber * _priority;
}

- (id) initWithDictionary:(NSDictionary *)json {
    self = [super init];
    if (self) {
        _name = [json objectForKey:kIGLUResolverName];
        _vendorPrefixes = [json objectForKey:kIGLUResolverVendor];
        _priority = [json objectForKey:kIGLUResolverPriority];
        
        NSDictionary * connection = [json objectForKey:kIGLUResolverConnection];
        NSArray * keys = [connection allKeys];
        if ([keys containsObject:kIGLUResolverTypeHttp]) {
            _type = kIGLUResolverTypeHttp;
            _uri = [[connection objectForKey:_type] objectForKey:kIGLUResolverUri];
        } else {
            _type = kIGLUResolverTypeEmbedded;
            _path = [[connection objectForKey:_type] objectForKey:kIGLUResolverPath];
        }
    }
    return self;
}

- (NSDictionary *)getSchemaForKey:(NSString *)key withBundles:(NSMutableArray *)bundles {
    // Strip 'iglu:' from key
    NSString * cleanKey = nil;
    if ([key hasPrefix:kIGLUSchemaPrefix]) {
        cleanKey = [key substringFromIndex:5];
    } else {
        NSLog(@"SchemaKey passed regex incorrectly: %@", key);
        return nil;
    }
    
    // Try to get schema based on connection type
    NSDictionary * result = nil;
    if ([_type  isEqual:kIGLUResolverTypeHttp]) {
        NSString * url = [NSString stringWithFormat:@"%@/%@/%@", _uri, kIGLUUriPathPrefix, cleanKey];
        NSString * json = [IGLUUtilities getStringWithUrlPath:url];
        if (json != nil) {
            result = [IGLUUtilities parseToJsonWithString:json];
        }
    } else {
        for (NSBundle * bundle in bundles) {
            result = [IGLUUtilities getJsonAsDictionaryWithFilePath:[NSString stringWithFormat:@"%@/%@", _path, cleanKey] andDirectory:nil andBundle:bundle];
            if (result != nil) {
                break;
            }
        }
    }
    
    return result;
}

- (NSString *)getName {
    return _name;
}

- (NSString *)getType {
    return _type;
}

- (NSString *)getUri {
    return _uri;
}

- (NSString *)getPath {
    return _path;
}

- (NSNumber *)getPriority {
    return _priority;
}

- (NSArray *)getVendorPrefixes {
    return _vendorPrefixes;
}

@end
