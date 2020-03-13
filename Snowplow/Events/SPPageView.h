//
//  SPPageView.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPPageViewBuilder
 @brief The protocol for building pageview events.
 */
@protocol SPPageViewBuilder <SPEventBuilder>

/*!
 @brief Set the URL of the page.

 @param pageUrl The URL of the page.
 */
- (void) setPageUrl:(NSString *)pageUrl;

/*!
 @brief Set the title of the page.

 @param pageTitle The title of the page.
 */
- (void) setPageTitle:(nullable NSString *)pageTitle;

/*!
 @brief Set the referrer of the pageview.

 @param referrer The pageview referrer.
 */
- (void) setReferrer:(nullable NSString *)referrer;
@end

/*!
 @class SPPageView
 @brief A pageview.
 */
@interface SPPageView : SPBuiltIn <SPPageViewBuilder>
+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock;
- (SPPayload *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
