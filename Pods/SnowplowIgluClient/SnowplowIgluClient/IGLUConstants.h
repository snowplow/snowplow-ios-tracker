//
//  IGLUConstants.h
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

#import <Foundation/Foundation.h>

@interface IGLUConstants : NSObject

// --- Version

extern NSString * const kIGLUVersion;

// --- Embedded Schemas

extern NSString * const kIGLUEmbeddedBundle;
extern NSString * const kIGLUEmbeddedDirectory;
extern NSString * const kIGLUInstanceIgluOnly;
extern NSString * const kIGLUResolverConfig;

// --- Regex

extern NSString * const kIGLUSchemaRegex;

// --- Resolvers

extern NSString * const kIGLUSchemaPrefix;

// --- HTTP

extern NSString * const kIGLUUriPathPrefix;

// --- Keys

extern NSString * const kIGLUKeySchema;
extern NSString * const kIGLUKeyData;

// --- Resolver Config Keys

extern NSString * const kIGLUResolverCacheSize;
extern NSString * const kIGLUResolverRepos;
extern NSString * const kIGLUResolverName;
extern NSString * const kIGLUResolverVendor;
extern NSString * const kIGLUResolverConnection;
extern NSString * const kIGLUResolverTypeHttp;
extern NSString * const kIGLUResolverTypeEmbedded;
extern NSString * const kIGLUResolverUri;
extern NSString * const kIGLUResolverPath;
extern NSString * const kIGLUResolverPriority;

@end
