//
//  SNOWGlobalContexts.h
//  Snowplow-iOS
//
//  Created by Michael Hadam on 5/31/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#ifndef SNOWGlobalContexts_h
#define SNOWGlobalContexts_h

@class SNOWContext;
@class SPPayload;
@class SPSelfDescribingJson;

@interface SNOWGlobalContexts : NSObject

@property (readonly) NSMutableArray<SNOWContext *> * contexts;

- (id) init;

- (void) addContext:(SNOWContext *)context;

- (void) addContexts:(NSArray<SNOWContext *> *)contexts;

- (bool) removeContextWithTag:(NSString *)tag;

- (bool) removeContextsWithTags:(NSArray<NSString *> *)tags;

- (void) removeAllContexts;

- (NSArray<SPSelfDescribingJson *> *) evaluateWithPayload:(SPPayload *)payload;

@end

#endif /* SNOWGlobalContexts_h */
