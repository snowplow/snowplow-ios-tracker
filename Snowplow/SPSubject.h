//
//  SPSubject.h
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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

@class SPPayload;

/*!
 @class SPSubject
 @brief The subject class.

 This class is used to access and persist user information, it represents the current user being tracked.
 */
@interface SPSubject : NSObject

/*!
 @brief Initializes a newly allocated SPSubject object.

 @return A new SPSubject.
 */
- (id) init;

/*!
 @brief Creates a subject which optionally adds platform and geolocation pairs.

 @param platformContext Whether to enable the platform context.
 @param geoContext Whether to enabled the geolocation context.
 @return A new SPSubject.
 */
- (id) initWithPlatformContext:(BOOL)platformContext andGeoContext:(BOOL)geoContext;

/*!
 @brief Gets all standard dictionary pairs to decorate the event with.

 @return A SPPayload with all standard pairs.
 */
- (SPPayload *) getStandardDict;

/*!
 @brief Gets all platform dictionary pairs to decorate event with.

 @return A SPPayload with all platform specific pairs.
 */
- (SPPayload *) getPlatformDict;

/*!
 @brief Gets the geolocation dictionary if the required keys are available.

 @return A dictionary with key-value pairs of the geolocation context.
 */
- (NSDictionary *) getGeoLocationDict;

/*!
 @brief Sets the user ID.

 @param uid The user's ID.
 */
- (void) setUserId:(NSString *)uid;

/*!
 @brief Sets the screen resolution.

 @param width The screen resolution width in pixels.
 @param height The screen resolution height in pixels.
 */
- (void) setResolutionWithWidth:(NSInteger)width andHeight:(NSInteger)height;

/*!
 @brief Sets the viewport dimensions.

 @param width The viewport width in pixels.
 @param height The viewport height in pixels.
 */
- (void) setViewPortWithWidth:(NSInteger)width andHeight:(NSInteger)height;

/*!
 @brief Sets the color depth.

 @param depth The user's color depth.
 */
- (void) setColorDepth:(NSInteger)depth;

/*!
 @brief Sets the timezone.

 @param timezone The user's timezone.
 */
- (void) setTimezone:(NSString *)timezone;

/*!
 @brief Sets the language.

 @param lang The user's language.
 */
- (void) setLanguage:(NSString *)lang;

/*!
 @brief Sets the IP Address.

 @param ip The user's IP address.
 */
- (void) setIpAddress:(NSString *)ip;

/*!
 @brief Sets the user agent (also known as browser string).

 @param useragent The user agent (also known as browser string).
 */
- (void) setUseragent:(NSString *)useragent;

/*!
 @brief Sets the Network User ID.

 @param nuid The network UID.
 */
- (void) setNetworkUserId:(NSString *)nuid;

/*!
 @brief Sets the Domain User ID.

 @param duid The domain UID.
 */
- (void) setDomainUserId:(NSString *)duid;

/*!
 @brief Sets the standard pairs for the Subject, called automatically on object creation.
 */
- (void) setStandardDict;

/*!
 @brief Optional mobile/desktop context, if selected will be automatically populated on object creation.
 */
- (void) setPlatformDict;

/*!
 @brief Optional geolocation context, if run will allocate memory for the geolocation context
 */
- (void) setGeoDict;

/*!
 @brief Sets the latitude value for the geolocation context.

 @param latitude A non-nil number.
 */
- (void) setGeoLatitude:(float)latitude;

/*!
 @brief Sets the longitude value for the geo context.

 @param longitude A non-nil number.
 */
- (void) setGeoLongitude:(float)longitude;

/*!
 @brief Sets the latitudeLongitudeAccuracy value for the geolocation context.

 @param latitudeLongitudeAccuracy A non-nil number
 */
- (void) setGeoLatitudeLongitudeAccuracy:(float)latitudeLongitudeAccuracy;

/*!
 @brief Sets the altitude value for the geolocation context.

 @param altitude A non-nil number.
 */
- (void) setGeoAltitude:(float)altitude;

/*!
 @brief Sets the altitudeAccuracy value for the geolocation context.

 @param altitudeAccuracy A non-nil number.
 */
- (void) setGeoAltitudeAccuracy:(float)altitudeAccuracy;

/*!
 @brief Sets the bearing value for the geolocation context.

 @param bearing A non-nil number.
 */
- (void) setGeoBearing:(float)bearing;

/*!
 @brief Sets the speed value for the geolocation context.

 @param speed A non-nil number.
 */
- (void) setGeoSpeed:(float)speed;

/*!
 @brief Sets the timestamp value for the geolocation context.

 @param timestamp The timestamp.
 */
- (void) setGeoTimestamp:(NSNumber *)timestamp;

@end

