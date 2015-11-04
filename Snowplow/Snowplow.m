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

#if SNOWPLOW_TARGET_IOS
NSString * const kSPVersion               = @"ios-0.6.0";
#elif SNOWPLOW_TARGET_TV
NSString * const kSPVersion               = @"tvos-0.6.0";
#else
NSString * const kSPVersion               = @"osx-0.6.0";
#endif

// --- Emitter

NSString * const kSPContentTypeHeader     = @"application/json; charset=utf-8";
NSString * const kSPAcceptContentHeader   = @"text/html, application/x-www-form-urlencoded, text/plain, image/gif";
NSInteger  const kSPDefaultBufferTimeout  = 60;
NSString * const kSPEndpointPost          = @"/com.snowplowanalytics.snowplow/tp2";
NSString * const kSPEndpointGet           = @"/i";

// --- Schema Paths

NSString * const kSPIglu                  = @"iglu";
NSString * const kSPSnowplowVendor        = @"com.snowplowanalytics.snowplow";
NSString * const kSPSchemaTag             = @"jsonschema";
NSString * const kSPPayloadDataSchema     = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-3";
NSString * const kSPUserTimingsSchema     = @"iglu:com.snowplowanalytics.snowplow/timing/jsonschema/1-0-0";
NSString * const kSPScreenViewSchema      = @"iglu:com.snowplowanalytics.snowplow/screen_view/jsonschema/1-0-0";
NSString * const kSPUnstructSchema        = @"iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0";
NSString * const kSPContextSchema         = @"iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-1";
NSString * const kSPMobileContextSchema   = @"iglu:com.snowplowanalytics.snowplow/mobile_context/jsonschema/1-0-1";
NSString * const kSPDesktopContextSchema  = @"iglu:com.snowplowanalytics.snowplow/desktop_context/jsonschema/1-0-0";
NSString * const kSPSessionContextSchema  = @"iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-1";
NSString * const kSPGeoContextSchema      = @"iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-1-0";

// --- Event Keys

NSString * const kSPEventPageView         = @"pv";
NSString * const kSPEventStructured       = @"se";
NSString * const kSPEventUnstructured     = @"ue";
NSString * const kSPEventEcomm            = @"tr";
NSString * const kSPEventEcommItem        = @"ti";

// --- General Keys

NSString * const kSPSchema                = @"schema";
NSString * const kSPData                  = @"data";
NSString * const kSPEvent                 = @"e";
NSString * const kSPEid                   = @"eid";
NSString * const kSPTimestamp             = @"dtm";
NSString * const kSPSentTimestamp         = @"stm";
NSString * const kSPTrackerVersion        = @"tv";
NSString * const kSPAppId                 = @"aid";
NSString * const kSPNamespace             = @"tna";
NSString * const kSPUid                   = @"uid";
NSString * const kSPContext               = @"co";
NSString * const kSPContextEncoded        = @"cx";
NSString * const kSPUnstructured          = @"ue_pr";
NSString * const kSPUnstructuredEncoded   = @"ue_px";

// --- Subject

NSString * const kSPPlatform              = @"p";
NSString * const kSPResolution            = @"res";
NSString * const kSPViewPort              = @"vp";
NSString * const kSPColorDepth            = @"cd";
NSString * const kSPTimezone              = @"tz";
NSString * const kSPLanguage              = @"lang";
NSString * const kSPIpAddress             = @"ip";
NSString * const kSPUseragent             = @"ua";
NSString * const kSPNetworkUid            = @"tnuid";
NSString * const kSPDomainUid             = @"duid";

// --- Platform Generic

NSString * const kSPPlatformOsType        = @"osType";
NSString * const kSPPlatformOsVersion     = @"osVersion";
NSString * const kSPPlatformDeviceManu    = @"deviceManufacturer";
NSString * const kSPPlatformDeviceModel   = @"deviceModel";

// --- Mobile Context

NSString * const kSPMobileCarrier         = @"carrier";
NSString * const kSPMobileOpenIdfa        = @"openIdfa";
NSString * const kSPMobileAppleIdfa       = @"appleIdfa";
NSString * const kSPMobileAppleIdfv       = @"appleIdfv";
NSString * const kSPMobileNetworkType     = @"networkType";
NSString * const kSPMobileNetworkTech     = @"networkTechnology";

// --- Session Context

NSString * const kSPSessionUserId         = @"userId";
NSString * const kSPSessionId             = @"sessionId";
NSString * const kSPSessionPreviousId     = @"previousSessionId";
NSString * const kSPSessionIndex          = @"sessionIndex";
NSString * const kSPSessionStorage        = @"storageMechanism";
NSString * const kSPSessionFirstEventId   = @"firstEventId";

// --- Geo-Location Context

NSString * const kSPGeoLatitude           = @"latitude";
NSString * const kSPGeoLongitude          = @"longitude";
NSString * const kSPGeoLatLongAccuracy    = @"latitudeLongitudeAccuracy";
NSString * const kSPGeoAltitude           = @"altitude";
NSString * const kSPGeoAltitudeAccuracy   = @"altitudeAccuracy";
NSString * const kSPGeoBearing            = @"bearing";
NSString * const kSPGeoSpeed              = @"speed";
NSString * const kSPGeoTimestamp          = @"timestamp";

// --- Page View Event

NSString * const kSPPageUrl               = @"url";
NSString * const kSPPageTitle             = @"page";
NSString * const kSPPageRefr              = @"refr";

// --- Structured Event

NSString * const kSPStuctCategory         = @"se_ca";
NSString * const kSPStuctAction           = @"se_ac";
NSString * const kSPStuctLabel            = @"se_la";
NSString * const kSPStuctProperty         = @"se_pr";
NSString * const kSPStuctValue            = @"se_va";

// --- E-commerce Transaction Event

NSString * const kSPEcommId               = @"tr_id";
NSString * const kSPEcommTotal            = @"tr_tt";
NSString * const kSPEcommAffiliation      = @"tr_af";
NSString * const kSPEcommTax              = @"tr_tx";
NSString * const kSPEcommShipping         = @"tr_sh";
NSString * const kSPEcommCity             = @"tr_ci";
NSString * const kSPEcommState            = @"tr_st";
NSString * const kSPEcommCountry          = @"tr_co";
NSString * const kSPEcommCurrency         = @"tr_cu";

// --- E-commerce Transaction Item Event

NSString * const kSPEcommItemId           = @"ti_id";
NSString * const kSPEcommItemSku          = @"ti_sk";
NSString * const kSPEcommItemName         = @"ti_nm";
NSString * const kSPEcommItemCategory     = @"ti_ca";
NSString * const kSPEcommItemPrice        = @"ti_pr";
NSString * const kSPEcommItemQuantity     = @"ti_qu";
NSString * const kSPEcommItemCurrency     = @"ti_cu";

// --- Screen View Event

NSString * const kSPSvId                  = @"id";
NSString * const kSPSvName                = @"name";

// --- User Timing Event

NSString * const kSPUtCategory            = @"category";
NSString * const kSPUtVariable            = @"variable";
NSString * const kSPUtTiming              = @"timing";
NSString * const kSPUtLabel               = @"label";

@end
