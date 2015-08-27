//
//  Snowplow.h
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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

#ifdef SNOWPLOW_DEBUG
#   define SnowplowDLog(...) NSLog(__VA_ARGS__)
#else
#   define SnowplowDLog(...)
#endif
#define ALog(...) NSLog(__VA_ARGS__)

@interface Snowplow : NSObject

// --- Version

extern NSString * const kVersion;

// --- Emitter

extern NSString * const kContentTypeHeader;
extern NSString * const kAcceptContentHeader;
extern NSInteger  const kDefaultBufferTimeout;
extern NSString * const kEndpointPost;
extern NSString * const kEndpointGet;

// --- Schema Paths

extern NSString * const kIglu;
extern NSString * const kSnowplowVendor;
extern NSString * const kSchemaTag;
extern NSString * const kPayloadDataSchema;
extern NSString * const kUserTimingsSchema;
extern NSString * const kScreenViewSchema;
extern NSString * const kUnstructSchema;
extern NSString * const kContextSchema;
extern NSString * const kMobileContextSchema;
extern NSString * const kDesktopContextSchema;
extern NSString * const kSessionContextSchema;

// --- Event Keys

extern NSString * const kEventPageView;
extern NSString * const kEventStructured;
extern NSString * const kEventUnstructured;
extern NSString * const KEventEcomm;
extern NSString * const kEventEcommItem;

// --- General Keys

extern NSString * const kSchema;
extern NSString * const kData;
extern NSString * const kEvent;
extern NSString * const kEid;
extern NSString * const kTimestamp;
extern NSString * const kSentTimestamp;
extern NSString * const kTrackerVersion;
extern NSString * const kAppId;
extern NSString * const kNamespace;
extern NSString * const kUid;
extern NSString * const kContext;
extern NSString * const kContextEncoded;
extern NSString * const kUnstructured;
extern NSString * const kUnstructuredEncoded;

// --- Subject

extern NSString * const kPlatform;
extern NSString * const kResolution;
extern NSString * const kViewPort;
extern NSString * const kColorDepth;
extern NSString * const kTimezone;
extern NSString * const kLanguage;
extern NSString * const kIpAddress;
extern NSString * const kUseragent;
extern NSString * const kNetworkUid;
extern NSString * const kDomainUid;

// --- Platform Generic

extern NSString * const kPlatformOsType;
extern NSString * const kPlatformOsVersion;
extern NSString * const kPlatformDeviceManu;
extern NSString * const kPlatformDeviceModel;

// --- Mobile Context

extern NSString * const kMobileCarrier;
extern NSString * const kMobileOpenIdfa;
extern NSString * const kMobileAppleIdfa;
extern NSString * const kMobileAppleIdfv;
extern NSString * const kMobileNetworkType;
extern NSString * const kMobileNetworkTech;

// --- Session Context

extern NSString * const kSessionUserId;
extern NSString * const kSessionId;
extern NSString * const kSessionPreviousId;
extern NSString * const kSessionIndex;
extern NSString * const kSessionStorage;

// --- Page View Event

extern NSString * const kPageUrl;
extern NSString * const kPageTitle;
extern NSString * const kPageRefr;

// --- Structured Event

extern NSString * const kStuctCategory;
extern NSString * const kStuctAction;
extern NSString * const kStuctLabel;
extern NSString * const kStuctProperty;
extern NSString * const kStuctValue;

// --- E-commerce Transaction Event

extern NSString * const kEcommId;
extern NSString * const kEcommTotal;
extern NSString * const kEcommAffiliation;
extern NSString * const kEcommTax;
extern NSString * const kEcommShipping;
extern NSString * const kEcommCity;
extern NSString * const kEcommState;
extern NSString * const kEcommCountry;
extern NSString * const kEcommCurrency;

// --- E-commerce Transaction Item Event

extern NSString * const kEcommItemId;
extern NSString * const kEcommItemSku;
extern NSString * const kEcommItemName;
extern NSString * const kEcommItemCategory;
extern NSString * const kEcommItemPrice;
extern NSString * const kEcommItemQuantity;
extern NSString * const kEcommItemCurrency;

// --- Screen View Event

extern NSString * const kSvId;
extern NSString * const kSvName;

// --- User Timing Event

extern NSString * const kUtCategory;
extern NSString * const kUtVariable;
extern NSString * const kUtTiming;
extern NSString * const kUtLabel;

@end
