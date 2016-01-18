//
//  Snowplow.h
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

// Macros to define what OS is running:
// 1. iOS: iOS == 1; OSX == 1; tvOS == 0
// 2. OSX: iOS == 0; OSX == 1; tvOS == 0
// 3. TV:  iOS == 1; OSX == 1; tvOS == 1
#define SNOWPLOW_TARGET_IOS (TARGET_OS_IPHONE && TARGET_OS_MAC && !(TARGET_OS_TV))
#define SNOWPLOW_TARGET_OSX (!(TARGET_OS_IPHONE) && TARGET_OS_MAC && !(TARGET_OS_TV))
#define SNOWPLOW_TARGET_TV  (TARGET_OS_IPHONE && TARGET_OS_MAC && TARGET_OS_TV)

// Macros for iOS Versions
#if SNOWPLOW_TARGET_IOS
#import <UIKit/UIDevice.h>
#define SNOWPLOW_iOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SNOWPLOW_iOS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#endif

// Macros for Logging
#ifdef SNOWPLOW_DEBUG
#   define SnowplowDLog(...) NSLog(__VA_ARGS__)
#else
#   define SnowplowDLog(...)
#endif
#define ALog(...) NSLog(__VA_ARGS__)

@interface Snowplow : NSObject

// --- Version

extern NSString * const kSPVersion;

// --- Emitter

extern NSString * const kSPContentTypeHeader;
extern NSString * const kSPAcceptContentHeader;
extern NSInteger  const kSPDefaultBufferTimeout;
extern NSString * const kSPEndpointPost;
extern NSString * const kSPEndpointGet;

// --- Schema Paths

extern NSString * const kSPIglu;
extern NSString * const kSPSnowplowVendor;
extern NSString * const kSPSchemaTag;
extern NSString * const kSPPayloadDataSchema;
extern NSString * const kSPUserTimingsSchema;
extern NSString * const kSPScreenViewSchema;
extern NSString * const kSPUnstructSchema;
extern NSString * const kSPContextSchema;
extern NSString * const kSPMobileContextSchema;
extern NSString * const kSPDesktopContextSchema;
extern NSString * const kSPSessionContextSchema;
extern NSString * const kSPGeoContextSchema;

// --- Event Keys

extern NSString * const kSPEventPageView;
extern NSString * const kSPEventStructured;
extern NSString * const kSPEventUnstructured;
extern NSString * const kSPEventEcomm;
extern NSString * const kSPEventEcommItem;

// --- General Keys

extern NSString * const kSPSchema;
extern NSString * const kSPData;
extern NSString * const kSPEvent;
extern NSString * const kSPEid;
extern NSString * const kSPTimestamp;
extern NSString * const kSPSentTimestamp;
extern NSString * const kSPTrackerVersion;
extern NSString * const kSPAppId;
extern NSString * const kSPNamespace;
extern NSString * const kSPUid;
extern NSString * const kSPContext;
extern NSString * const kSPContextEncoded;
extern NSString * const kSPUnstructured;
extern NSString * const kSPUnstructuredEncoded;

// --- Subject

extern NSString * const kSPPlatform;
extern NSString * const kSPResolution;
extern NSString * const kSPViewPort;
extern NSString * const kSPColorDepth;
extern NSString * const kSPTimezone;
extern NSString * const kSPLanguage;
extern NSString * const kSPIpAddress;
extern NSString * const kSPUseragent;
extern NSString * const kSPNetworkUid;
extern NSString * const kSPDomainUid;

// --- Platform Generic

extern NSString * const kSPPlatformOsType;
extern NSString * const kSPPlatformOsVersion;
extern NSString * const kSPPlatformDeviceManu;
extern NSString * const kSPPlatformDeviceModel;

// --- Mobile Context

extern NSString * const kSPMobileCarrier;
extern NSString * const kSPMobileOpenIdfa;
extern NSString * const kSPMobileAppleIdfa;
extern NSString * const kSPMobileAppleIdfv;
extern NSString * const kSPMobileNetworkType;
extern NSString * const kSPMobileNetworkTech;

// --- Session Context

extern NSString * const kSPSessionUserId;
extern NSString * const kSPSessionId;
extern NSString * const kSPSessionPreviousId;
extern NSString * const kSPSessionIndex;
extern NSString * const kSPSessionStorage;
extern NSString * const kSPSessionFirstEventId;

// --- Geo-Location Context

extern NSString * const kSPGeoLatitude;
extern NSString * const kSPGeoLongitude;
extern NSString * const kSPGeoLatLongAccuracy;
extern NSString * const kSPGeoAltitude;
extern NSString * const kSPGeoAltitudeAccuracy;
extern NSString * const kSPGeoBearing;
extern NSString * const kSPGeoSpeed;
extern NSString * const kSPGeoTimestamp;

// --- Page View Event

extern NSString * const kSPPageUrl;
extern NSString * const kSPPageTitle;
extern NSString * const kSPPageRefr;

// --- Structured Event

extern NSString * const kSPStuctCategory;
extern NSString * const kSPStuctAction;
extern NSString * const kSPStuctLabel;
extern NSString * const kSPStuctProperty;
extern NSString * const kSPStuctValue;

// --- E-commerce Transaction Event

extern NSString * const kSPEcommId;
extern NSString * const kSPEcommTotal;
extern NSString * const kSPEcommAffiliation;
extern NSString * const kSPEcommTax;
extern NSString * const kSPEcommShipping;
extern NSString * const kSPEcommCity;
extern NSString * const kSPEcommState;
extern NSString * const kSPEcommCountry;
extern NSString * const kSPEcommCurrency;

// --- E-commerce Transaction Item Event

extern NSString * const kSPEcommItemId;
extern NSString * const kSPEcommItemSku;
extern NSString * const kSPEcommItemName;
extern NSString * const kSPEcommItemCategory;
extern NSString * const kSPEcommItemPrice;
extern NSString * const kSPEcommItemQuantity;
extern NSString * const kSPEcommItemCurrency;

// --- Screen View Event

extern NSString * const kSPSvId;
extern NSString * const kSPSvName;

// --- User Timing Event

extern NSString * const kSPUtCategory;
extern NSString * const kSPUtVariable;
extern NSString * const kSPUtTiming;
extern NSString * const kSPUtLabel;

@end
