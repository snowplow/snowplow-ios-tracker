//
//  IGLUConstants.m
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

@implementation IGLUConstants

// --- Version

NSString * const kIGLUVersion               = @"iglu-objc-client-0.1.0";

// --- Embedded Directory

NSString * const kIGLUEmbeddedBundle        = @"SnowplowIgluResources";
NSString * const kIGLUEmbeddedDirectory     = @"Resources/iglu-client-embedded/schemas";
NSString * const kIGLUInstanceIgluOnly      = @"iglu:com.snowplowanalytics.self-desc/instance-iglu-only/jsonschema/1-0-0";
NSString * const kIGLUResolverConfig        = @"iglu:com.snowplowanalytics.iglu/resolver-config/jsonschema/1-0-0";

// --- Regex

NSString * const kIGLUSchemaRegex           = @"^iglu:([a-zA-Z0-9-_.]+)/([a-zA-Z0-9-_]+)/([a-zA-Z0-9-_]+)/((?:[0-9]+-)?[0-9]+-[0-9]+)$";

// --- Resolvers

NSString * const kIGLUSchemaPrefix          = @"iglu:";

// --- HTTP

NSString * const kIGLUUriPathPrefix         = @"schemas";

// --- Keys

NSString * const kIGLUKeySchema             = @"schema";
NSString * const kIGLUKeyData               = @"data";

// --- Resolver Config Keys

NSString * const kIGLUResolverCacheSize     = @"cacheSize";
NSString * const kIGLUResolverRepos         = @"repositories";
NSString * const kIGLUResolverName          = @"name";
NSString * const kIGLUResolverVendor        = @"vendorPrefixes";
NSString * const kIGLUResolverConnection    = @"connection";
NSString * const kIGLUResolverTypeHttp      = @"http";
NSString * const kIGLUResolverTypeEmbedded  = @"embedded";
NSString * const kIGLUResolverUri           = @"uri";
NSString * const kIGLUResolverPath          = @"path";
NSString * const kIGLUResolverPriority      = @"priority";

@end
