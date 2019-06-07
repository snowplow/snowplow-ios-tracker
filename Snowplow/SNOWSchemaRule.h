//
//  SNOWSchemaRule.h
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/6/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#ifndef SNOWSchemaRule_h
#define SNOWSchemaRule_h

@interface SNOWSchemaRule : NSObject <NSCopying>

@property (readwrite, copy) NSString * rule;
@property (readwrite, copy) NSArray<NSString *> * ruleParts;

- (id) init;

- (id) initWithRule:(NSString *)rule NS_DESIGNATED_INITIALIZER;

+ (NSArray *) getPartsFromURI:(NSString *)uri;

- (bool) match:(NSString *)uri;

/*!
 @brief Override for equality.
 */
- (BOOL) isEqual: (id)other;

/*!
 @brief Override for hash. Calculated using the schema URI string, if it exists - otherwise 0.
 */
- (NSUInteger) hash;

@end

#endif /* SNOWSchemaRule_h */
