//
//  SPRequestResponse.h
//  Snowplow
//
//  Copyright (c) 2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@interface SPRequestResponse : NSObject

/**
 * Creates a request response object
 */
- (id) init;

/**
 * Creates a request response object
 * @param success whether the operation was a success or not
 * @param index the event indexes in the database
 */
- (id) initWithBool:(BOOL)success withIndex:(NSArray *)index;

/**
 * Returns the success of the request operation.
 * @return the success state
 */
- (BOOL) getSuccess;

/**
 * Returns the stored index array, needed to remove the events after sending.
 * @return the index array to be used while removing sent event
 */
- (NSMutableArray *) getIndexArray;

@end
