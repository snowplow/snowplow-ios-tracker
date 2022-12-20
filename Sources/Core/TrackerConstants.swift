//
//  TrackerConstants.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

import Foundation

// --- Version
#if os(iOS)
let kSPVersion = "ios-5.0.0-alpha.2"
#elseif os(tvOS)
let kSPVersion = "tvos-5.0.0-alpha.2"
#elseif os(watchOS)
let kSPVersion = "watchos-5.0.0-alpha.2"
#else
let kSPVersion = "osx-5.0.0-alpha.2"
#endif

// --- Session Dictionary keys
let kSPInstallationUserId = "SPInstallationUserId"

// --- Emitter
let kSPContentTypeHeader = "application/json; charset=utf-8"
let kSPAcceptContentHeader = "text/html, application/x-www-form-urlencoded, text/plain, image/gif"
let kSPDefaultBufferTimeout = 60
let kSPEndpointPost = "/com.snowplowanalytics.snowplow/tp2"
let kSPEndpointGet = "/i"

// --- Schema Paths
let kSPIglu = "iglu"
let kSPSnowplowVendor = "com.snowplowanalytics.snowplow"
let kSPSchemaTag = "jsonschema"
let kSPPayloadDataSchema = "iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-4"
let kSPUserTimingsSchema = "iglu:com.snowplowanalytics.snowplow/timing/jsonschema/1-0-0"
let kSPScreenViewSchema = "iglu:com.snowplowanalytics.mobile/screen_view/jsonschema/1-0-0"
let kSPUnstructSchema = "iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0"
let kSPContextSchema = "iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-1"
let kSPMobileContextSchema = "iglu:com.snowplowanalytics.snowplow/mobile_context/jsonschema/1-0-2"
let kSPDesktopContextSchema = "iglu:com.snowplowanalytics.snowplow/desktop_context/jsonschema/1-0-0"
let kSPSessionContextSchema = "iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-2"
let kSPScreenContextSchema = "iglu:com.snowplowanalytics.mobile/screen/jsonschema/1-0-0"
let kSPGeoContextSchema = "iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-1-0"
let kSPConsentDocumentSchema = "iglu:com.snowplowanalytics.snowplow/consent_document/jsonschema/1-0-0"
let kSPConsentGrantedSchema = "iglu:com.snowplowanalytics.snowplow/consent_granted/jsonschema/1-0-0"
let kSPConsentWithdrawnSchema = "iglu:com.snowplowanalytics.snowplow/consent_withdrawn/jsonschema/1-0-0"
let kSPPushNotificationSchema = "iglu:com.apple/notification_event/jsonschema/1-0-1"
let kSPApplicationContextSchema = "iglu:com.snowplowanalytics.mobile/application/jsonschema/1-0-0"
let kSPForegroundSchema = "iglu:com.snowplowanalytics.snowplow/application_foreground/jsonschema/1-0-0"
let kSPBackgroundSchema = "iglu:com.snowplowanalytics.snowplow/application_background/jsonschema/1-0-0"
let kSPErrorSchema = "iglu:com.snowplowanalytics.snowplow/application_error/jsonschema/1-0-2"
let kSPApplicationInstallSchema = "iglu:com.snowplowanalytics.mobile/application_install/jsonschema/1-0-0"
let kSPGdprContextSchema = "iglu:com.snowplowanalytics.snowplow/gdpr/jsonschema/1-0-0"
let kSPDiagnosticErrorSchema = "iglu:com.snowplowanalytics.snowplow/diagnostic_error/jsonschema/1-0-0"

// --- Event Keys
let kSPEventPageView = "pv"
let kSPEventStructured = "se"
let kSPEventUnstructured = "ue"
let kSPEventEcomm = "tr"
let kSPEventEcommItem = "ti"

// --- General Keys
let kSPSchema = "schema"
let kSPData = "data"
let kSPEvent = "e"
let kSPEid = "eid"
let kSPTimestamp = "dtm"
let kSPTrueTimestamp = "ttm"
let kSPSentTimestamp = "stm"
let kSPTrackerVersion = "tv"
let kSPAppId = "aid"
let kSPNamespace = "tna"
let kSPUid = "uid"
let kSPContext = "co"
let kSPContextEncoded = "cx"
let kSPUnstructured = "ue_pr"
let kSPUnstructuredEncoded = "ue_px"

// --- Subject
let kSPPlatform = "p"
let kSPResolution = "res"
let kSPViewPort = "vp"
let kSPColorDepth = "cd"
let kSPTimezone = "tz"
let kSPLanguage = "lang"
let kSPIpAddress = "ip"
let kSPUseragent = "ua"
let kSPNetworkUid = "tnuid"
let kSPDomainUid = "duid"

// --- Platform Generic
let kSPPlatformOsType = "osType"
let kSPPlatformOsVersion = "osVersion"
let kSPPlatformDeviceManu = "deviceManufacturer"
let kSPPlatformDeviceModel = "deviceModel"

// --- Mobile Context
let kSPMobileCarrier = "carrier"
let kSPMobileAppleIdfa = "appleIdfa"
let kSPMobileAppleIdfv = "appleIdfv"
let kSPMobileNetworkType = "networkType"
let kSPMobileNetworkTech = "networkTechnology"
let kSPMobilePhysicalMemory = "physicalMemory"
let kSPMobileAppAvailableMemory = "appAvailableMemory"
let kSPMobileBatteryLevel = "batteryLevel"
let kSPMobileBatteryState = "batteryState"
let kSPMobileLowPowerMode = "lowPowerMode"
let kSPMobileAvailableStorage = "availableStorage"
let kSPMobileTotalStorage = "totalStorage"

// --- Application Context
let kSPApplicationVersion = "version"
let kSPApplicationBuild = "build"

// --- Session Context
let kSPSessionUserId = "userId"
let kSPSessionId = "sessionId"
let kSPSessionPreviousId = "previousSessionId"
let kSPSessionIndex = "sessionIndex"
let kSPSessionStorage = "storageMechanism"
let kSPSessionFirstEventId = "firstEventId"
let kSPSessionFirstEventTimestamp = "firstEventTimestamp"
let kSPSessionEventIndex = "eventIndex"
let kSPSessionAnonymousUserId = "00000000-0000-0000-0000-000000000000"

// --- Geo-Location Context
let kSPGeoLatitude = "latitude"
let kSPGeoLongitude = "longitude"
let kSPGeoLatLongAccuracy = "latitudeLongitudeAccuracy"
let kSPGeoAltitude = "altitude"
let kSPGeoAltitudeAccuracy = "altitudeAccuracy"
let kSPGeoBearing = "bearing"
let kSPGeoSpeed = "speed"
let kSPGeoTimestamp = "timestamp"

// --- Screen Context
let kSPScreenName = "name"
let kSPScreenType = "type"
let kSPScreenId = "id"
let kSPScreenViewController = "viewController"
let kSPScreenTopViewController = "topViewController"

// --- Page View Event
let kSPPageUrl = "url"
let kSPPageTitle = "page"
let kSPPageRefr = "refr"

// --- Structured Event
let kSPStuctCategory = "se_ca"
let kSPStuctAction = "se_ac"
let kSPStuctLabel = "se_la"
let kSPStuctProperty = "se_pr"
let kSPStuctValue = "se_va"

// --- E-commerce Transaction Event
let kSPEcommId = "tr_id"
let kSPEcommTotal = "tr_tt"
let kSPEcommAffiliation = "tr_af"
let kSPEcommTax = "tr_tx"
let kSPEcommShipping = "tr_sh"
let kSPEcommCity = "tr_ci"
let kSPEcommState = "tr_st"
let kSPEcommCountry = "tr_co"
let kSPEcommCurrency = "tr_cu"

// --- E-commerce Transaction Item Event
let kSPEcommItemId = "ti_id"
let kSPEcommItemSku = "ti_sk"
let kSPEcommItemName = "ti_nm"
let kSPEcommItemCategory = "ti_ca"
let kSPEcommItemPrice = "ti_pr"
let kSPEcommItemQuantity = "ti_qu"
let kSPEcommItemCurrency = "ti_cu"

// --- Consent Granted Event
let KSPCgExpiry = "expiry"

// --- Consent Withdrawn Event
let KSPCwAll = "all"

// --- Consent Document Event
let kSPCdId = "id"
let kSPCdVersion = "version"
let kSPCdName = "name"
let KSPCdDescription = "description"

// --- Screen View Event
let kSPSvName = "name"
let kSPSvType = "type"
let kSPSvScreenId = "id"
let kSPSvPreviousName = "previousName"
let kSPSvPreviousType = "previousType"
let kSPSvPreviousScreenId = "previousId"
let kSPSvTransitionType = "transitionType"
let kSPSvViewController = "viewController"
let kSPSvTopViewController = "topViewController"

// --- User Timing Event
let kSPUtCategory = "category"
let kSPUtVariable = "variable"
let kSPUtTiming = "timing"
let kSPUtLabel = "label"

// --- Push Notification Event
let kSPPushAction = "action"
let kSPPushTrigger = "trigger"
let kSPPushDeliveryDate = "deliveryDate"
let kSPPushCategoryId = "categoryIdentifier"
let kSPPushThreadId = "threadIdentifier"
let kSPPushNotificationParam = "notification"
let kSPPnTitle = "title"
let kSPPnSubtitle = "subtitle"
let kSPPnBody = "body"
let kSPPnBadge = "badge"
let kSPPnSound = "sound"
let kSPPnLaunchImageName = "launchImageName"
let kSPPnUserInfo = "userInfo"
let kSPPnAttachments = "attachments"
let kSPPnAttachmentId = "identifier"
let kSPPnAttachmentUrl = "url"
let kSPPnAttachmentType = "type"

// --- Foreground Event
let kSPBackgroundIndex = "backgroundIndex"

// --- Background Event
let kSPForegroundIndex = "foregroundIndex"

// --- Error Event
let kSPErrorName = "exceptionName"
let kSPErrorStackTrace = "stackTrace"
let kSPErrorLanguage = "programmingLanguage"
let kSPErrorMessage = "message"

// --- Error Event - Tracker Settings Storage
let kSPErrorTrackerUrl = "url"
let kSPErrorTrackerProtocol = "protocol"
let kSPErrorTrackerMethod = "method"

// --- Install tracking
let kSPInstalledBefore = "SPInstalledBefore"
let kSPInstallTimestamp = "SPInstallTimestamp"
let kSPPreviousInstallVersion = "SPInstallVersion"
let kSPPreviousInstallBuild = "SPInstallBuild"

// --- GDPR Context
let kSPBasisForProcessing = "basisForProcessing"
let kSPDocumentId = "documentId"
let kSPDocumentVersion = "documentVersion"
let kSPDocumentDescription = "documentDescription"

// --- Tracker Diagnostic
let kSPDiagnosticErrorMessage = "message"
let kSPDiagnosticErrorStack = "stackTrace"
let kSPDiagnosticErrorClassName = "className"
let kSPDiagnosticErrorExceptionName = "exceptionName"
