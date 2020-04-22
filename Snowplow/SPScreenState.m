//
//  SPScreenState.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Michael Hadam
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPScreenState.h"
#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@implementation SPScreenState

- (id) init {
    return [self initWithName:nil type:nil screenId:nil transitionType:nil topViewControllerClassName:nil viewControllerClassName:nil];
}

- (id) initWithName:(id)theName type:(id)theType screenId:(id)theScreenId transitionType:(id)theTransitionType topViewControllerClassName:(id)theTopControllerName viewControllerClassName:(id)theControllerName {
    if (self = [super init]) {
        _name = theName;
        if (!theScreenId) {
            _screenId = [[NSUUID UUID] UUIDString];
        } else {
            _screenId = theScreenId;
        }
        _type = theType;
        _transitionType = theTransitionType;
        _topViewControllerClassName = theTopControllerName;
        _viewControllerClassName = theControllerName;
        return self;
    }
    return nil;
}

- (id) initWithName:theName type:theType topViewControllerClassName:(id)theTopControllerName viewControllerClassName:(id)theControllerName {
    return [self initWithName:theName type:theType screenId:nil transitionType:nil topViewControllerClassName:theTopControllerName viewControllerClassName:theControllerName];
}

- (id) initWithName:theName type:theType screenId:theScreenId transitionType:theTransitionType {
    return [self initWithName:theName type:theType screenId:theScreenId transitionType:nil topViewControllerClassName:nil viewControllerClassName:nil];
}

- (id) initWithName:theName type:theType screenId:theScreenId {
    return [self initWithName:theName type:theType screenId:theScreenId transitionType:nil];
}

- (id) initWithName:theName screenId:theScreenId {
    return [self initWithName:theName type:nil screenId:theScreenId transitionType:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    SPScreenState * state = [[[self class] allocWithZone:zone] init];
    return [state initWithName:self.name
                          type:self.type
                      screenId:self.screenId
                transitionType:self.transitionType
    topViewControllerClassName:self.topViewControllerClassName
       viewControllerClassName:self.viewControllerClassName];
}

- (BOOL) isValid {
    return ([SPUtilities validateString:self.name] != nil) &&
    ([SPUtilities validateString:self.screenId] != nil) &&
    [SPUtilities isUUIDString:self.screenId];
}

- (SPPayload *) getValidPayload {
    if ([self isValid]) {
        SPPayload * validPayload = [[SPPayload alloc] init];
        [validPayload addValueToPayload:self.name forKey:kSPScreenName];
        [validPayload addValueToPayload:self.screenId forKey:kSPScreenId];
        [validPayload addValueToPayload:[SPUtilities validateString:self.type] forKey:kSPScreenType];
        [validPayload addValueToPayload:[SPUtilities validateString:self.topViewControllerClassName] forKey:kSPScreenTopViewController];
        [validPayload addValueToPayload:[SPUtilities validateString:self.viewControllerClassName] forKey:kSPScreenViewController];
        return validPayload;
    } else {
        return nil;
    }
}

@end
