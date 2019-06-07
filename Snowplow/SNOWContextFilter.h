//
//  SNOWContextFilter.h
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/4/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#ifndef SNOWContextFilter_h
#define SNOWContextFilter_h

@class SPPayload;

/*!
 @brief Block signature for context generators, takes event information and generates a context.
 @param event event JSON in the form of an NSDictionary
 @param eventType event type taken from 'e' field found in payload_data (tracker protocol schema) event
 @param eventSchema event schema taken from 'ue_pr'/'ue_px' payload schema field - not present for all events (no first-class events like pageview, etc.)
 @return return whether to attach associated context primtive (self-describing JSON or generator)
 */
typedef bool (^filterBlock)(SPPayload * event, NSString * eventType, NSString * eventSchema);

@interface SNOWContextFilter : NSObject <NSCopying>

@property (readwrite, copy) filterBlock filter;

- (id) copyWithZone:(NSZone *)zone;

- (id) init;

- (id) initWithFilter:(filterBlock)filter NS_DESIGNATED_INITIALIZER;

- (bool) evaluateWithPayload:(SPPayload *)payload andEventType:(NSString *)type andSchemaURI:(NSString *)schema;

@end

#endif /* SNOWContextFilter_h */
