//
//  Snowplow.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"

@implementation Snowplow

// --- Version

#if TARGET_OS_IPHONE
NSString * const kVersion               = @"ios-0.4.0";
#else
NSString * const kVersion               = @"osx-0.4.0";
#endif

// --- Emitter

NSString * const kContentTypeHeader     = @"application/json; charset=utf-8";
NSString * const kAcceptContentHeader   = @"text/html, application/x-www-form-urlencoded, text/plain, image/gif";
NSInteger  const kDefaultBufferTimeout  = 60;
NSString * const kEndpointPost          = @"/com.snowplowanalytics.snowplow/tp2";
NSString * const kEndpointGet           = @"/i";

// --- Schema Paths

NSString * const kIglu                  = @"iglu";
NSString * const kSnowplowVendor        = @"com.snowplowanalytics.snowplow";
NSString * const kSchemaTag             = @"jsonschema";
NSString * const kPayloadDataSchema     = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-3";
NSString * const kUserTimingsSchema     = @"iglu:com.snowplowanalytics.snowplow/timing/jsonschema/1-0-0";
NSString * const kScreenViewSchema      = @"iglu:com.snowplowanalytics.snowplow/screen_view/jsonschema/1-0-0";
NSString * const kUnstructSchema        = @"iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0";
NSString * const kContextSchema         = @"iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-1";
NSString * const kMobileContextSchema   = @"iglu:com.snowplowanalytics.snowplow/mobile_context/jsonschema/1-0-0";
NSString * const kDesktopContextSchema  = @"iglu:com.snowplowanalytics.snowplow/desktop_context/jsonschema/1-0-0";
NSString * const kSessionContextSchema  = @"iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-0";

// --- Event Keys

NSString * const kEventPageView         = @"pv";
NSString * const kEventStructured       = @"se";
NSString * const kEventUnstructured     = @"ue";
NSString * const KEventEcomm            = @"tr";
NSString * const kEventEcommItem        = @"ti";

// --- General Keys

NSString * const kSchema                = @"schema";
NSString * const kData                  = @"data";
NSString * const kEvent                 = @"e";
NSString * const kEid                   = @"eid";
NSString * const kTimestamp             = @"dtm";
NSString * const kSentTimestamp         = @"stm";
NSString * const kTrackerVersion        = @"tv";
NSString * const kAppId                 = @"aid";
NSString * const kNamespace             = @"tna";
NSString * const kUid                   = @"uid";
NSString * const kContext               = @"co";
NSString * const kContextEncoded        = @"cx";
NSString * const kUnstructured          = @"ue_pr";
NSString * const kUnstructuredEncoded   = @"ue_px";

// --- Subject

NSString * const kPlatform              = @"p";
NSString * const kResolution            = @"res";
NSString * const kViewPort              = @"vp";
NSString * const kColorDepth            = @"cd";
NSString * const kTimezone              = @"tz";
NSString * const kLanguage              = @"lang";
NSString * const kIpAddress             = @"ip";
NSString * const kUseragent             = @"ua";
NSString * const kNetworkUid            = @"tnuid";
NSString * const kDomainUid             = @"duid";

// --- Platform Generic

NSString * const kPlatformOsType        = @"osType";
NSString * const kPlatformOsVersion     = @"osVersion";
NSString * const kPlatformDeviceManu    = @"deviceManufacturer";
NSString * const kPlatformDeviceModel   = @"deviceModel";

// --- Mobile Context

NSString * const kMobileCarrier         = @"carrier";
NSString * const kMobileOpenIdfa        = @"openIdfa";
NSString * const kMobileAppleIdfa       = @"appleIdfa";
NSString * const kMobileAppleIdfv       = @"appleIdfv";
NSString * const kMobileNetworkType     = @"networkType";
NSString * const kMobileNetworkTech     = @"networkTechnology";

// --- Session Context

NSString * const kSessionUserId         = @"userId";
NSString * const kSessionId             = @"sessionId";
NSString * const kSessionPreviousId     = @"previousSessionId";
NSString * const kSessionIndex          = @"sessionIndex";
NSString * const kSessionStorage        = @"storageMechanism";

// --- Page View Event

NSString * const kPageUrl               = @"url";
NSString * const kPageTitle             = @"page";
NSString * const kPageRefr              = @"refr";

// --- Structured Event

NSString * const kStuctCategory         = @"se_ca";
NSString * const kStuctAction           = @"se_ac";
NSString * const kStuctLabel            = @"se_la";
NSString * const kStuctProperty         = @"se_pr";
NSString * const kStuctValue            = @"se_va";

// --- E-commerce Transaction Event

NSString * const kEcommId               = @"tr_id";
NSString * const kEcommTotal            = @"tr_tt";
NSString * const kEcommAffiliation      = @"tr_af";
NSString * const kEcommTax              = @"tr_tx";
NSString * const kEcommShipping         = @"tr_sh";
NSString * const kEcommCity             = @"tr_ci";
NSString * const kEcommState            = @"tr_st";
NSString * const kEcommCountry          = @"tr_co";
NSString * const kEcommCurrency         = @"tr_cu";

// --- E-commerce Transaction Item Event

NSString * const kEcommItemId           = @"ti_id";
NSString * const kEcommItemSku          = @"ti_sk";
NSString * const kEcommItemName         = @"ti_nm";
NSString * const kEcommItemCategory     = @"ti_ca";
NSString * const kEcommItemPrice        = @"ti_pr";
NSString * const kEcommItemQuantity     = @"ti_qu";
NSString * const kEcommItemCurrency     = @"ti_cu";

// --- Screen View Event

NSString * const kSvId                  = @"id";
NSString * const kSvName                = @"name";

// --- User Timing Event

NSString * const kUtCategory            = @"category";
NSString * const kUtVariable            = @"variable";
NSString * const kUtTiming              = @"timing";
NSString * const kUtLabel               = @"label";

@end
