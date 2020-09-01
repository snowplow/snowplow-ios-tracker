//
//  Snowplow.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"

@implementation Snowplow

// --- Version

#if SNOWPLOW_TARGET_IOS
NSString * const kSPVersion               = @"ios-1.5.0";
#elif SNOWPLOW_TARGET_TV
NSString * const kSPVersion               = @"tvos-1.5.0";
#elif SNOWPLOW_TARGET_WATCHOS
NSString * const kSPVersion               = @"watchos-1.5.0";
#else
NSString * const kSPVersion               = @"osx-1.5.0";
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
NSString * const kSPPayloadDataSchema     = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-4";
NSString * const kSPUserTimingsSchema     = @"iglu:com.snowplowanalytics.snowplow/timing/jsonschema/1-0-0";
NSString * const kSPScreenViewSchema      = @"iglu:com.snowplowanalytics.mobile/screen_view/jsonschema/1-0-0";
NSString * const kSPUnstructSchema        = @"iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0";
NSString * const kSPContextSchema         = @"iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-1";
NSString * const kSPMobileContextSchema   = @"iglu:com.snowplowanalytics.snowplow/mobile_context/jsonschema/1-0-1";
NSString * const kSPDesktopContextSchema  = @"iglu:com.snowplowanalytics.snowplow/desktop_context/jsonschema/1-0-0";
NSString * const kSPSessionContextSchema  = @"iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-1";
NSString * const kSPScreenContextSchema   = @"iglu:com.snowplowanalytics.mobile/screen/jsonschema/1-0-0";
NSString * const kSPGeoContextSchema      = @"iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-1-0";
NSString * const kSPConsentDocumentSchema = @"iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0";
NSString * const kSPConsentGrantedSchema = @"iglu:com.snowplowanalytics.snowplow/consent_granted/jsonschema/1-0-0";
NSString * const kSPConsentWithdrawnSchema = @"iglu:com.snowplowanalytics.snowplow/consent_withdrawn/jsonschema/1-0-0";
NSString * const kSPPushNotificationSchema = @"iglu:com.apple/notification_event/jsonschema/1-0-0";
NSString * const kSPApplicationContextSchema = @"iglu:com.snowplowanalytics.mobile/application/jsonschema/1-0-0";
NSString * const kSPForegroundSchema = @"iglu:com.snowplowanalytics.snowplow/application_foreground/jsonschema/1-0-0";
NSString * const kSPBackgroundSchema = @"iglu:com.snowplowanalytics.snowplow/application_background/jsonschema/1-0-0";
NSString * const kSPErrorSchema = @"iglu:com.snowplowanalytics.snowplow/application_error/jsonschema/1-0-2";
NSString * const kSPApplicationInstallSchema = @"iglu:com.snowplowanalytics.mobile/application_install/jsonschema/1-0-0";
NSString * const kSPGdprContextSchema     = @"iglu:com.snowplowanalytics.snowplow/gdpr/jsonschema/1-0-0";
NSString * const kSPDiagnosticErrorSchema = @"iglu:com.snowplowanalytics.snowplow/diagnostic_error/jsonschema/1-0-0";

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
NSString * const kSPTrueTimestamp         = @"ttm";
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

// --- Application Context

NSString * const kSPApplicationVersion    = @"version";
NSString * const kSPApplicationBuild      = @"build";

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

// --- Screen Context
NSString * const kSPScreenName                = @"name";
NSString * const kSPScreenType                = @"type";
NSString * const kSPScreenId                  = @"id";
NSString * const kSPScreenViewController      = @"viewController";
NSString * const kSPScreenTopViewController   = @"topViewController";

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

// --- Consent Granted Event
NSString * const KSPCgExpiry              = @"expiry";

// --- Consent Withdrawn Event
NSString * const KSPCwAll                 = @"all";

// --- Consent Document Event
NSString * const kSPCdId                  = @"id";
NSString * const kSPCdVersion             = @"version";
NSString * const kSPCdName                = @"name";
NSString * const KSPCdDescription         = @"description";

// --- Screen View Event

NSString * const kSPSvName                    = @"name";
NSString * const kSPSvType                    = @"type";
NSString * const kSPSvScreenId                = @"id";
NSString * const kSPSvPreviousName            = @"previousName";
NSString * const kSPSvPreviousType            = @"previousType";
NSString * const kSPSvPreviousScreenId        = @"previousId";
NSString * const kSPSvTransitionType          = @"transitionType";
NSString * const kSPSvViewController          = @"viewController";
NSString * const kSPSvTopViewController       = @"topViewController";


// --- User Timing Event

NSString * const kSPUtCategory            = @"category";
NSString * const kSPUtVariable            = @"variable";
NSString * const kSPUtTiming              = @"timing";
NSString * const kSPUtLabel               = @"label";

// --- Push Notification Event

NSString * const kSPPushAction            = @"action";
NSString * const kSPPushTrigger           = @"trigger";
NSString * const kSPPushDeliveryDate      = @"deliveryDate";
NSString * const kSPPushCategoryId        = @"categoryIdentifier";
NSString * const kSPPushThreadId          = @"threadIdentifier";
NSString * const kSPPushNotification      = @"notification";
NSString * const kSPPnTitle               = @"title";
NSString * const kSPPnSubtitle            = @"subtitle";
NSString * const kSPPnBody                = @"body";
NSString * const kSPPnBadge               = @"badge";
NSString * const kSPPnSound               = @"sound";
NSString * const kSPPnLaunchImageName     = @"launchImageName";
NSString * const kSPPnUserInfo            = @"userInfo";
NSString * const kSPPnAttachments         = @"attachments";
NSString * const kSPPnAttachmentId        = @"identifier";
NSString * const kSPPnAttachmentUrl       = @"url";
NSString * const kSPPnAttachmentType      = @"type";

// --- Foreground Event

NSString * const kSPBackgroundIndex       = @"backgroundIndex";

// --- Background Event

NSString * const kSPForegroundIndex       = @"foregroundIndex";

// --- Error Event

NSString * const kSPErrorName             = @"exceptionName";
NSString * const kSPErrorStackTrace       = @"stackTrace";
NSString * const kSPErrorLanguage         = @"programmingLanguage";
NSString * const kSPErrorMessage          = @"message";

// --- Error Event - Tracker Settings Storage

NSString * const kSPErrorTrackerUrl       = @"url";
NSString * const kSPErrorTrackerProtocol  = @"protocol";
NSString * const kSPErrorTrackerMethod    = @"method";

// --- Install tracking

NSString * const kSPInstalledBefore        = @"SPInstalledBefore";
NSString * const kSPInstallTimestamp       = @"SPInstallTimestamp";
NSString * const kSPPreviousInstallVersion = @"SPInstallVersion";
NSString * const kSPPreviousInstallBuild   = @"SPInstallBuild";

// --- GDPR Context

NSString * const kSPBasisForProcessing  = @"basisForProcessing";
NSString * const kSPDocumentId          = @"documentId";
NSString * const kSPDocumentVersion     = @"documentVersion";
NSString * const kSPDocumentDescription = @"documentDescription";

// --- Tracker Diagnostic

NSString * const kSPDiagnosticErrorMessage       = @"message";
NSString * const kSPDiagnosticErrorStack         = @"stackTrace";
NSString * const kSPDiagnosticErrorClassName     = @"className";
NSString * const kSPDiagnosticErrorExceptionName = @"exceptionName";

@end
