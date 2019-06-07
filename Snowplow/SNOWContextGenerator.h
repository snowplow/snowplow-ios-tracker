//
//  SNOWContextGenerator.h
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/5/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

@class SPPayload;
@class SPSelfDescribingJson;

#ifndef SNOWContextGenerator_h
#define SNOWContextGenerator_h

/*!
 @brief Block signature for context generators, takes event information and generates a context.
 @param event event JSON in the form of an NSDictionary
 @param eventType event type taken from 'e' field found in payload_data (tracker protocol schema) event
 @param eventSchema event schema taken from 'ue_pr'/'ue_px' payload schema field - not present for all events (no first-class events like pageview, etc.)
 @return a user-generated self-describing JSON
 */
typedef NSArray<SPSelfDescribingJson *> * (^SNOWGeneratorBlock)(SPPayload * event, NSString * eventType, NSString * eventSchema);

@interface SNOWContextGenerator : NSObject <NSCopying>

@property (copy, readwrite) SNOWGeneratorBlock block;

- (id)copyWithZone:(NSZone *)zone;

- (id) initWithBlock:(SNOWGeneratorBlock)block NS_DESIGNATED_INITIALIZER;

- (NSArray<SPSelfDescribingJson *> *) evaluateWithPayload:(SPPayload *)payload andEventType:(NSString *)type andSchemaURI:(NSString *)schema;

@end

#endif /* SNOWContextGenerator_h */
