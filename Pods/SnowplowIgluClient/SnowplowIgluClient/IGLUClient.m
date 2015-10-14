//
//  IGLUClient.m
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
#import "IGLUClient.h"
#import "IGLUUtilities.h"
#import "IGLUResolver.h"
#import "IGLUSchema.h"
#import "KiteJSONValidator.h"

@implementation IGLUClient {
    NSNumber * _cacheSize;
    NSMutableArray * _resolvers;
    KiteJSONValidator * _jsonValidator;
    NSMutableArray * _bundles;
    NSMutableDictionary * _cachedSchemas;
    NSMutableDictionary * _failedSchemas;
    NSRegularExpression * _schemaRegex;
}

- (id)initWithJsonString:(NSString *)json andBundles:(NSMutableArray *)bundles {
    self = [super init];
    if (self) {
        // Parse String and ensure it validates
        NSDictionary * jsonDict = [IGLUUtilities parseToJsonWithString:json];
        [IGLUUtilities checkArgument:(jsonDict != nil)
                         withMessage:[NSString stringWithFormat:@"FATAL: Could not parse %@ to a JSON Dictionary.", json]];
        
        // Init Variables
        _resolvers = [[NSMutableArray alloc] init];
        _cachedSchemas = [[NSMutableDictionary alloc] init];
        _failedSchemas = [[NSMutableDictionary alloc] init];
        _bundles = [[NSMutableArray alloc] init];
        _jsonValidator = [KiteJSONValidator new];
        
        // Compile Regex
        _schemaRegex = [NSRegularExpression regularExpressionWithPattern:kIGLUSchemaRegex options:0 error:nil];
        
        // Add bundles
        NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:kIGLUEmbeddedBundle ofType:@"bundle"];
        if (path != nil) {
            [_bundles addObject:[NSBundle bundleWithPath:path]];
        }
        if (bundles != nil) {
            [_bundles addObjectsFromArray:bundles];
        }
        
        // Make Embedded Resolver
        [_resolvers addObject:[self getSelfEmbeddedResolver]];
        
        // Validated Resolver Config
        [IGLUUtilities checkArgument:[self validateJson:jsonDict]
                         withMessage:[NSString stringWithFormat:@"FATAL: Iglu Resolver did not pass validation."]];
        
        // Store Cache Size
        NSDictionary * jsonDictData = [jsonDict objectForKey:kIGLUKeyData];
        _cacheSize = [jsonDictData objectForKey:kIGLUResolverCacheSize];
        
        // Create Resolvers
        for (NSDictionary * repoJson in [jsonDictData objectForKey:kIGLUResolverRepos]) {
            IGLUResolver * resolver = [[IGLUResolver alloc] initWithDictionary:repoJson];
            if (resolver != nil) {
                [_resolvers addObject:resolver];
            }
        }
        
        // Order the resolvers by priority
        _resolvers = [self orderResolversByPriority:_resolvers];
    }
    return self;
}

- (id)initWithUrlPath:(NSString *)urlPath andBundles:(NSMutableArray *)bundles {
    return [self initWithJsonString:[IGLUUtilities getStringWithUrlPath:urlPath] andBundles:bundles];
}

- (NSMutableArray *)orderResolversByPriority:(NSMutableArray *)resolvers {
    NSArray * orderedResolvers = [[NSArray alloc] init];
    orderedResolvers = [resolvers sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(IGLUResolver*)a getPriority];
        NSNumber *second = [(IGLUResolver*)b getPriority];
        return [first compare:second];
    }];
    return [[NSMutableArray alloc] initWithArray:orderedResolvers];
}

- (BOOL)validateJson:(NSDictionary *)json {
    BOOL result = NO;
    NSString * error = nil;
    
    if (json == nil) {
        NSLog(@"JSON Dictionary is nil; cannot check.");
        return result;
    }
    
    // First pass validation to check that:
    // - json: is a valid Iglu SelfDescribingJson
    NSString * schemaKey = kIGLUInstanceIgluOnly;
    NSDictionary * schema = [self getSchemaWithKey:schemaKey];
    
    if (schema != nil) {
        if ([_jsonValidator validateJSONInstance:json withSchema:schema]) {
            // Second pass validation to check that:
            // - json: is valid against its own schema
            schemaKey = [json objectForKey:kIGLUKeySchema];
            schema = [self getSchemaWithKey:schemaKey];
            
            if (schema != nil) {
                if ([_jsonValidator validateJSONInstance:[json objectForKey:kIGLUKeyData] withSchema:schema]) {
                    result = YES;
                } else {
                    error = [NSString stringWithFormat:@"The JSON did not validate against its own JSONSchema: '%@'", schemaKey];
                }
            } else {
                error = [NSString stringWithFormat:@"Could not match the key '%@' against any of the available resolvers.", schemaKey];
            }
        } else {
            error = [NSString stringWithFormat:@"The JSON did not validate against the instance-iglu-only JSONSchema"];
        }
    } else {
        error = [NSString stringWithFormat:@"Could not match the key '%@' against any of the available resolvers.", schemaKey];
    }
    
    if (error != nil) {
        NSLog(@"%@", error);
    }
    
    return result;
}

- (NSDictionary *)getSchemaWithKey:(NSString *)key {
    // Check Failed Cache
    if ([_failedSchemas objectForKey:key] != nil) {
        return nil;
    }
    
    // Check Success Cache
    IGLUSchema * schema = [_cachedSchemas objectForKey:key];
    if (schema != nil) {
        return [schema getSchema];
    }
    
    // Check Resolvers
    schema = [[IGLUSchema alloc] initWithKey:key andSchema:nil andRegex:_schemaRegex];
    NSDictionary * schemaDict = nil;
    
    // Check all resolvers with matching vendor prefixes
    NSMutableArray * untested = [[NSMutableArray alloc] init];
    for (IGLUResolver * resolver in _resolvers) {
        if ([[resolver getVendorPrefixes] containsObject:[schema getVendor]]) {
            schemaDict = [resolver getSchemaForKey:key withBundles:_bundles];
            
            if (schemaDict != nil) {
                [schema setSchema:schemaDict];
                [_cachedSchemas setObject:schema forKey:key];
                return [schema getSchema];
            }
        } else {
            [untested addObject:resolver];
        }
    }
    
    // Check other resolvers if schema not found
    if ([untested count] != 0) {
        for (IGLUResolver * resolver in untested) {
            schemaDict = [resolver getSchemaForKey:key withBundles:_bundles];
            
            if (schemaDict != nil) {
                [schema setSchema:schemaDict];
                [_cachedSchemas setObject:schema forKey:key];
                return [schema getSchema];
            }
        }
    }
    
    // Add to Failed Cache if nothing can be found
    [_failedSchemas setObject:schema forKey:key];
    return nil;
}

- (void)addToBundles:(NSBundle *)bundle {
    if (bundle != nil) {
        [_bundles addObject:bundle];
    }
}

- (NSMutableArray *)getBundles {
    return _bundles;
}

- (IGLUResolver *)getSelfEmbeddedResolver {
    NSMutableArray * vendors = [[NSMutableArray alloc] init];
    [vendors addObject:@"com.snowplowanalytics.self-desc"];
    [vendors addObject:@"com.snowplowanalytics.iglu"];
    NSMutableDictionary * path = [[NSMutableDictionary alloc] init];
    [path setObject:kIGLUEmbeddedDirectory forKey:kIGLUResolverPath];
    NSMutableDictionary * embedded = [[NSMutableDictionary alloc] init];
    [embedded setObject:path forKey:kIGLUResolverTypeEmbedded];
    NSMutableDictionary * selfRepo = [[NSMutableDictionary alloc] init];
    [selfRepo setObject:@"Self Embedded" forKey:kIGLUResolverName];
    [selfRepo setObject:vendors forKey:kIGLUResolverVendor];
    [selfRepo setObject:embedded forKey:kIGLUResolverConnection];
    [selfRepo setObject:[NSNumber numberWithInt:-1] forKey:kIGLUResolverPriority];
    
    return [[IGLUResolver alloc] initWithDictionary:selfRepo];
}

- (NSMutableArray *)getResolvers {
    return _resolvers;
}

- (NSInteger)getCacheSize {
    return [_cacheSize integerValue];
}

- (NSInteger)getSuccessSize {
    return [_cachedSchemas count];
}

- (NSInteger)getFailedSize {
    return [_failedSchemas count];
}

- (void)clearCaches {
    [_cachedSchemas removeAllObjects];
    [_failedSchemas removeAllObjects];
}

@end
