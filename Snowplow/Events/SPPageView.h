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
- (void) setPageTitle:(NSString *)pageTitle;

/*!
 @brief Set the referrer of the pageview.

 @param referrer The pageview referrer.
 */
- (void) setReferrer:(NSString *)referrer;
@end

/*!
 @class SPPageView
 @brief A pageview.
 */
@interface SPPageView : SPEvent <SPPageViewBuilder>
+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

NS_ASSUME_NONNULL_END
