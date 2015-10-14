//
//  IGLUSchema.m
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
#import "IGLUSchema.h"
#import "IGLUUtilities.h"

@implementation IGLUSchema {
    BOOL _valid;
    NSString * _vendor;
    NSString * _name;
    NSString * _format;
    NSString * _version;
    NSDictionary * _schema;
    NSString * _invalidKey;
}

- (id)initWithKey:(NSString *)key andSchema:(NSDictionary *)schema andRegex:(NSRegularExpression *)regex {
    self = [super init];
    if (self) {
        _valid = [self setKeyWithSchemaKey:key andRegex:regex];
        _schema = schema;
    }
    return self;
}

- (BOOL)setKeyWithSchemaKey:(NSString *)key andRegex:(NSRegularExpression *)regex {
    NSTextCheckingResult * match = [regex firstMatchInString:key options:0 range:NSMakeRange(0, [key length])];
    if (match != nil) {
        _vendor  = [key substringWithRange:[match rangeAtIndex:1]];
        _name    = [key substringWithRange:[match rangeAtIndex:2]];
        _format  = [key substringWithRange:[match rangeAtIndex:3]];
        _version = [key substringWithRange:[match rangeAtIndex:4]];
        return YES;
    } else {
        _invalidKey = key;
        return NO;
    }
}

- (void)setSchema:(NSDictionary *)schema {
    _schema = schema;
}

- (BOOL)getValid {
    return _valid;
}

- (NSString *)getVendor {
    return _vendor;
}

- (NSString *)getName {
    return _name;
}

- (NSString *)getFormat {
    return _format;
}

- (NSString *)getVersion {
    return _version;
}

- (NSDictionary *)getSchema {
    return _schema;
}

- (NSString *)getKey {
    if (_valid) {
        return [NSString stringWithFormat:@"%@%@/%@/%@/%@", kIGLUSchemaPrefix, _vendor, _name, _format, _version];
    } else {
        return _invalidKey;
    }
}

@end
