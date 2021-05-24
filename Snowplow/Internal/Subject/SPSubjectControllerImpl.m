//
//  SPSubjectControllerImpl.m
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPSubjectControllerImpl.h"
#import "SPPayload.h"


@interface SPSubjectControllerImpl ()

@property (nonatomic, weak) SPSubject *subject;

@end


@implementation SPSubjectControllerImpl
@synthesize userId;
@synthesize networkUserId;
@synthesize domainUserId;
@synthesize useragent;
@synthesize ipAddress;
@synthesize timezone;
@synthesize language;
@synthesize screenResolution;
@synthesize screenViewPort;
@synthesize colorDepth;

@synthesize geoLatitude;
@synthesize geoLongitude;
@synthesize geoLatitudeLongitudeAccuracy;
@synthesize geoAltitude;
@synthesize geoAltitudeAccuracy;
@synthesize geoSpeed;
@synthesize geoBearing;
@synthesize geoTimestamp;

- (instancetype)initWithSubject:(SPSubject *)subject {
    if (self = [super init]) {
        self.subject = subject;
    }
    return self;
}

// MARK: - Properties

- (void)setUserId:(NSString *)userId {
    [self.subject setUserId:userId];
}

- (NSString *)userId {
    return self.subject.userId;
}

- (void)setNetworkUserId:(NSString *)networkUserId {
    [self.subject setNetworkUserId:networkUserId];
}

- (NSString *)networkUserId {
    return [self.subject networkUserId];
}

- (void)setDomainUserId:(NSString *)domainUserId {
    [self.subject setDomainUserId:domainUserId];
}

- (NSString *)domainUserId {
    return [self.subject domainUserId];
}

- (void)setUseragent:(NSString *)useragent {
    [self.subject setUseragent:useragent];
}

- (NSString *)useragent {
    return [self.subject useragent];
}

- (void)setIpAddress:(NSString *)ipAddress {
    [self.subject setIpAddress:ipAddress];
}

- (NSString *)ipAddress {
    return [self.subject ipAddress];
}

- (void)setTimezone:(NSString *)timezone {
    [self.subject setTimezone:timezone];
}

- (NSString *)timezone {
    return [self.subject timezone];
}

- (void)setLanguage:(NSString *)language {
    [self.subject setLanguage:language];
}

- (NSString *)language {
    return [self.subject language];
}

- (void)setScreenResolution:(SPSize *)screenResolution {
    [self.subject setResolutionWithWidth:screenResolution.width andHeight:screenResolution.height];
}

- (SPSize *)screenResolution {
    return [self.subject screenResolution];
}

- (void)setScreenViewPort:(SPSize *)screenViewPort {
    [self.subject setViewPortWithWidth:screenResolution.width andHeight:screenResolution.height];
}

- (SPSize *)screenViewPort {
    return [self.subject screenViewPort];
}

- (void)setColorDepth:(NSNumber *)colorDepth {
    [self.subject setColorDepth:colorDepth.intValue];
}

- (NSNumber *)colorDepth {
    return @([self.subject colorDepth]);
}

// MARK: - GeoLocalization

- (void)setGeoLatitude:(NSNumber *)geoLatitude {
    [self.subject setGeoLatitude:geoLatitude.floatValue];
}

- (NSNumber *)geoLatitude {
    return [self.subject geoLatitude];
}

- (void)setGeoLongitude:(NSNumber *)geoLongitude {
    [self.subject setGeoLongitude:geoLongitude.floatValue];
}

- (NSNumber *)geoLongitude {
    return [self.subject geoLongitude];
}

- (void)setGeoLatitudeLongitudeAccuracy:(NSNumber *)geoLatitudeLongitudeAccuracy {
    [self.subject setGeoLatitudeLongitudeAccuracy:geoLatitudeLongitudeAccuracy.floatValue];
}

- (NSNumber *)geoLatitudeLongitudeAccuracy {
    return [self.subject geoLatitudeLongitudeAccuracy];
}

- (void)setGeoAltitude:(NSNumber *)geoAltitude {
    [self.subject setGeoAltitude:geoAltitude.floatValue];
}

- (NSNumber *)geoAltitude {
    return [self.subject geoAltitude];
}

- (void)setGeoAltitudeAccuracy:(NSNumber *)geoAltitudeAccuracy {
    [self.subject setGeoAltitudeAccuracy:geoAltitudeAccuracy.floatValue];
}

- (NSNumber *)geoAltitudeAccuracy {
    return [self.subject geoAltitudeAccuracy];
}

- (void)setGeoSpeed:(NSNumber *)geoSpeed {
    [self.subject setGeoSpeed:geoSpeed.floatValue];
}

- (NSNumber *)geoSpeed {
    return [self.subject geoSpeed];
}

- (void)setGeoBearing:(NSNumber *)geoBearing {
    [self.subject setGeoBearing:geoBearing.floatValue];
}

- (NSNumber *)geoBearing {
    return [self.subject geoBearing];
}

- (void)setGeoTimestamp:(NSNumber *)geoTimestamp {
    [self.subject setGeoTimestamp:geoTimestamp];
}

- (NSNumber *)geoTimestamp {
    return [self.subject geoTimestamp];
}

@end

