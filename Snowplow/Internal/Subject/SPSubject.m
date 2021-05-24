//
//  SPSubject.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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

#import "SPTrackerConstants.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#import "SPLogger.h"


@implementation SPSubject {
    SPPayload *           _standardDict;
    SPPayload *           _platformDict;
    NSMutableDictionary * _geoLocationDict;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (id) init {
    return [self initWithPlatformContext:false andGeoContext:false];
}

- (id) initWithPlatformContext:(BOOL)platformContext andGeoContext:(BOOL)geoContext {
    return [self initWithPlatformContext:platformContext geoLocationContext:geoContext subjectConfiguration:nil];
}

- (instancetype)initWithPlatformContext:(BOOL)platformContext geoLocationContext:(BOOL)geoContext subjectConfiguration:(SPSubjectConfiguration *)config {
    if (self = [super init]) {
        self.platformContext = platformContext;
        self.geoLocationContext = geoContext;
        _standardDict = [[SPPayload alloc] init];
        [self setStandardDict];
        [self setPlatformDict];
        [self setGeoDict];
        if (config) {
            if (config.userId) [self setUserId:config.userId];
            if (config.networkUserId) [self setNetworkUserId:config.networkUserId];
            if (config.domainUserId) [self setDomainUserId:config.domainUserId];
            if (config.useragent) [self setUseragent:config.useragent];
            if (config.ipAddress) [self setIpAddress:config.ipAddress];
            NSString *timezone = config.timezone ?: [NSTimeZone localTimeZone].name;
            if (timezone) [self setTimezone:timezone];
            NSString *language = config.language ?: [NSLocale preferredLanguages].firstObject;
            if (config.language) [self setLanguage:language];
            if (config.screenResolution) {
                SPSize *size = config.screenResolution;
                [self setResolutionWithWidth:size.width andHeight:size.height];
            }
            if (config.screenViewPort) {
                SPSize *size = config.screenViewPort;
                [self setViewPortWithWidth:size.width andHeight:size.height];
            }
            if (config.colorDepth) {
                [self setColorDepth:config.colorDepth.integerValue];
            }
            // geolocation
            if (config.geoLatitude) {
                [self setGeoLatitude:config.geoLatitude.floatValue];
            }
            if (config.geoLongitude) {
                [self setGeoLongitude:config.geoLongitude.floatValue];
            }
            if (config.geoLatitudeLongitudeAccuracy) {
                [self setGeoLatitudeLongitudeAccuracy:config.geoLatitudeLongitudeAccuracy.floatValue];
            }
            if (config.geoAltitude) {
                [self setGeoAltitude:config.geoAltitude.floatValue];
            }
            if (config.geoAltitudeAccuracy) {
                [self setGeoAltitudeAccuracy:config.geoAltitudeAccuracy.floatValue];
            }
            if (config.geoSpeed) {
                [self setGeoSpeed:config.geoSpeed.floatValue];
            }
            if (config.geoBearing) {
                [self setGeoBearing:config.geoBearing.floatValue];
            }
            if (config.geoTimestamp) {
                [self setGeoTimestamp:config.geoTimestamp];
            }
        }
    }
    return self;
}

#pragma clang diagnostic pop

- (SPPayload *) getStandardDict {
    return _standardDict;
}

- (SPPayload *) getPlatformDict {
    return _platformDict;
}

- (NSDictionary *) getGeoLocationDict {
    if (_geoLocationDict[kSPGeoLatitude] && _geoLocationDict[kSPGeoLongitude]) {
        return _geoLocationDict;
    } else {
        SPLogDebug(@"GeoLocation missing required fields; cannot get.");
        return nil;
    }
}

// MARK: - Standard Dictionary

- (void) setStandardDict {
    [_standardDict addValueToPayload:[SPUtilities getResolution] forKey:kSPResolution];
    [_standardDict addValueToPayload:[SPUtilities getViewPort]   forKey:kSPViewPort];
    [_standardDict addValueToPayload:[SPUtilities getLanguage]   forKey:kSPLanguage];
}

- (void) setUserId:(NSString *)uid {
    _userId = uid;
    [_standardDict addValueToPayload:uid forKey:kSPUid];
}

- (void) identifyUser:(NSString *)uid {
    [self setUserId:uid];
}

- (void) setResolutionWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    _screenResolution = [[SPSize alloc] initWithWidth:width height:height];
    NSString * res = [NSString stringWithFormat:@"%@x%@", [@(width) stringValue], [@(height) stringValue]];
    [_standardDict addValueToPayload:res forKey:kSPResolution];
}

- (void) setViewPortWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    _screenViewPort = [[SPSize alloc] initWithWidth:width height:height];
    NSString * res = [NSString stringWithFormat:@"%@x%@", [@(width) stringValue], [@(height) stringValue]];
    [_standardDict addValueToPayload:res forKey:kSPViewPort];
}

- (void) setColorDepth:(NSInteger)depth {
    _colorDepth = depth;
    NSString * res = [NSString stringWithFormat:@"%@", [@(depth) stringValue]];
    [_standardDict addValueToPayload:res forKey:kSPColorDepth];
}

- (void) setTimezone:(NSString *)timezone {
    _timezone = timezone;
    [_standardDict addValueToPayload:timezone forKey:kSPTimezone];
}

- (void) setLanguage:(NSString *)lang {
    _language = lang;
    [_standardDict addValueToPayload:lang forKey:kSPLanguage];
}

- (void) setIpAddress:(NSString *)ip {
    _ipAddress = ip;
    [_standardDict addValueToPayload:ip forKey:kSPIpAddress];
}

- (void) setUseragent:(NSString *)useragent {
    _useragent = useragent;
    [_standardDict addValueToPayload:useragent forKey:kSPUseragent];
}

- (void) setNetworkUserId:(NSString *)nuid {
    _networkUserId = nuid;
    [_standardDict addValueToPayload:nuid forKey:kSPNetworkUid];
}

- (void) setDomainUserId:(NSString *)duid {
    _domainUserId = duid;
    [_standardDict addValueToPayload:duid forKey:kSPDomainUid];
}

// MARK: - Platform Dictionary

- (void) setPlatformDict {
    _platformDict = [[SPPayload alloc] init];
    [_platformDict addValueToPayload:[SPUtilities getOSType]            forKey:kSPPlatformOsType];
    [_platformDict addValueToPayload:[SPUtilities getOSVersion]         forKey:kSPPlatformOsVersion];
    [_platformDict addValueToPayload:[SPUtilities getDeviceVendor]      forKey:kSPPlatformDeviceManu];
    [_platformDict addValueToPayload:[SPUtilities getDeviceModel]       forKey:kSPPlatformDeviceModel];
#if SNOWPLOW_TARGET_IOS
    [self setMobileDict];
#endif
}

- (void) setMobileDict {
    [_platformDict addValueToPayload:[SPUtilities getCarrierName]       forKey:kSPMobileCarrier];
    [_platformDict addValueToPayload:[SPUtilities getAppleIdfa]         forKey:kSPMobileAppleIdfa];
    [_platformDict addValueToPayload:[SPUtilities getAppleIdfv]         forKey:kSPMobileAppleIdfv];
    [_platformDict addValueToPayload:[SPUtilities getNetworkType]       forKey:kSPMobileNetworkType];
    [_platformDict addValueToPayload:[SPUtilities getNetworkTechnology] forKey:kSPMobileNetworkTech];
}

// MARK: - GeoLocation Dictionary

- (void) setGeoDict {
    _geoLocationDict = [[NSMutableDictionary alloc] init];
}

- (void) setGeoLatitude:(float)latitude {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:latitude] forKey:kSPGeoLatitude];
}

- (NSNumber *)geoLatitude {
    return (NSNumber *)_geoLocationDict[kSPGeoLatitude];
}

- (void) setGeoLongitude:(float)longitude {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:longitude] forKey:kSPGeoLongitude];
}

- (NSNumber *)geoLongitude {
    return (NSNumber *)_geoLocationDict[kSPGeoLongitude];
}

- (void) setGeoLatitudeLongitudeAccuracy:(float)latitudeLongitudeAccuracy {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:latitudeLongitudeAccuracy] forKey:kSPGeoLatLongAccuracy];
}

- (NSNumber *)geoLatitudeLongitudeAccuracy {
    return (NSNumber *)_geoLocationDict[kSPGeoLatLongAccuracy];
}

- (void) setGeoAltitude:(float)altitude {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:altitude] forKey:kSPGeoAltitude];
}

- (NSNumber *)geoAltitude {
    return (NSNumber *)_geoLocationDict[kSPGeoAltitude];
}

- (void) setGeoAltitudeAccuracy:(float)altitudeAccuracy {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:altitudeAccuracy] forKey:kSPGeoAltitudeAccuracy];
}

- (NSNumber *)geoAltitudeAccuracy {
    return (NSNumber *)_geoLocationDict[kSPGeoAltitudeAccuracy];
}

- (void) setGeoBearing:(float)bearing {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:bearing] forKey:kSPGeoBearing];
}

- (NSNumber *)geoBearing {
    return (NSNumber *)_geoLocationDict[kSPGeoBearing];
}

- (void) setGeoSpeed:(float)speed {
    [_geoLocationDict setObject:[NSNumber numberWithFloat:speed] forKey:kSPGeoSpeed];
}

- (NSNumber *)geoSpeed {
    return (NSNumber *)_geoLocationDict[kSPGeoSpeed];
}

- (void) setGeoTimestamp:(NSNumber *)timestamp {
    [_geoLocationDict setObject:timestamp forKey:kSPGeoTimestamp];
}

- (NSNumber *)geoTimestamp {
    return (NSNumber *)_geoLocationDict[kSPGeoTimestamp];
}

@end
