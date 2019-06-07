//
//  SNOWContext.h
//  Snowplow-iOS
//
//  Created by Michael Hadam on 5/31/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#ifndef SNOWContext_h
#define SNOWContext_h

@class SPPayload;
@class SPSelfDescribingJson;
@class SNOWSchemaRuleset;
@class SNOWContextGenerator;
@class SNOWContextFilter;

@interface SNOWContext : NSObject <NSCopying>

@property (readwrite, copy) SNOWSchemaRuleset * ruleset;
@property (readwrite, copy) SNOWContextFilter * filter;
@property (readwrite, copy) NSMutableArray<SNOWContextGenerator *> * generators;
@property (readwrite, copy) NSMutableArray<SPSelfDescribingJson *> * contexts;
@property (readwrite, copy) NSString * tag;

- (id) init;

- (id) initWithFilter:(SNOWContextFilter *)filter andGenerator:(SNOWContextGenerator *)generator;
- (id) initWithFilter:(SNOWContextFilter *)filter andContext:(SPSelfDescribingJson *)context;
- (id) initWithFilter:(SNOWContextFilter *)filter andCollection:(NSArray *)collection;

- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andGenerator:(SNOWContextGenerator *)generator;
- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andContext:(SPSelfDescribingJson *)context;
- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset andCollection:(NSArray *)collection;

- (id) initWithGenerator:(SNOWContextGenerator *)generator;
- (id) initWithContext:(SPSelfDescribingJson *)context;
- (id) initWithCollection:(NSArray *)collection;

- (id) initWithRuleset:(SNOWSchemaRuleset *)ruleset
             andFilter:(SNOWContextFilter *)filter
         andCollection:(NSArray *)collection NS_DESIGNATED_INITIALIZER;

- (NSArray<SPSelfDescribingJson *> *) evaluateWithPayload:(SPPayload *)payload
                                             andEventType:(NSString *)type
                                             andSchemaURI:(NSString *)schema;

@end

#endif /* SNOWContext_h */
