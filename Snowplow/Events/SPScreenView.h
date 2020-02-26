//
//  SPScreenView.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPScreenViewBuilder
 @brief The protocol for building screenview events.
 */
@protocol SPScreenViewBuilder <SPEventBuilder>
/*!
 @brief Set the name of the screen.

 @param name The name of the screen.
 */
- (void) setName:(NSString *)name;

/*!
 @brief Set the type of the screen.

 @param type The type for the screen.
 */
- (void) setType:(NSString *)type;

/*!
 @brief Set the ID of the screen.

 @param screenId The ID for the screen.
 */
- (void) setScreenId:(NSString *)screenId;

/*!
 @brief Set the name of the previous screen.

 @param name The name of the previous screen.
 */
- (void) setPreviousScreenName:(NSString *)name;

/*!
 @brief Set the type of the previous screen.

 @param type The type of the previous screen.
 */
- (void) setPreviousScreenType:(NSString *)type;

/*!
 @brief Set the ID of the previous screen.

 @param screenId The ID for the previous screen.
 */
- (void) setPreviousScreenId:(NSString *)screenId;

/*!
 @brief Set the type of the screen transition.

 @param type The type of the screen transition.
 */
- (void) setTransitionType:(NSString *)type;

- (void) setViewControllerClassName:(NSString *)className;

- (void) setTopViewControllerClassName:(NSString *)className;

@end

/*!
 @class SPScreenView
 @brief A screenview event.
 */
@interface SPScreenView : SPEvent <SPScreenViewBuilder>
+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
- (SPScreenState *) getScreenState;
- (BOOL) updateWithPreviousState:(SPScreenState *)previousState;
@end


NS_ASSUME_NONNULL_END
