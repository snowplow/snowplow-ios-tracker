//
//  SNOWSchemaRuleset.h
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/3/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#ifndef SNOWSchemaRuleset_h
#define SNOWSchemaRuleset_h

@class SNOWSchemaRule;

@interface SNOWSchemaRuleset : NSObject <NSCopying>

@property (readwrite, copy) NSMutableArray<SNOWSchemaRule *> * deny;
@property (readwrite, copy) NSMutableArray<SNOWSchemaRule *> * allow;

- (id) init;

- (id) initWithAllowList:(NSArray<NSString *> *)allow;

- (id) initWithDenyList:(NSArray<NSString *> *)deny;

- (id) initWithAllowList:(NSArray<NSString *> *)allow andDenyList:(NSArray<NSString *> *)deny NS_DESIGNATED_INITIALIZER;

- (bool) evaluateWithSchemaURI:(NSString *)uri;

@end

#endif /* SNOWSchemaRuleset_h */
