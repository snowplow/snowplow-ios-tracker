//
//  SPGDPRControllerImpl.m
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

#import "SPGDPRControllerImpl.h"
#import "SPGdprContext.h"
#import "SPTracker.h"
#import "SPGDPRConfigurationUpdate.h"

@interface SPGDPRControllerImpl ()

@property (nonatomic, nullable) SPGdprContext *gdpr;

@end

@implementation SPGDPRControllerImpl

// MARK: - Methods

- (void)resetWithBasis:(SPGdprProcessingBasis)basisForProcessing
            documentId:(nullable NSString *)documentId
       documentVersion:(nullable NSString *)documentVersion
   documentDescription:(nullable NSString *)documentDescription
{
    [self.tracker setGdprContextWithBasis:basisForProcessing
                               documentId:documentId
                          documentVersion:documentVersion
                      documentDescription:documentDescription];
    self.gdpr = self.tracker.gdprContext;
    self.dirtyConfig.gdpr = self.gdpr;
    self.dirtyConfig.gdprUpdated = YES;
}

- (void)disable {
    self.dirtyConfig.isEnabled = NO;
    [self.tracker disableGdprContext];
}

- (BOOL)isEnabled {
    return self.tracker.gdprContext != nil;
}

- (BOOL)enable {
    if (!self.gdpr) {
        return NO;
    }
    [self.tracker enableGdprContextWithBasis:self.gdpr.basis
                                  documentId:self.gdpr.documentId
                             documentVersion:self.gdpr.documentVersion
                         documentDescription:self.gdpr.documentDescription];
    self.dirtyConfig.isEnabled = YES;
    return YES;
}

- (SPGdprProcessingBasis)basisForProcessing {
    return [self.gdpr basis];
}

- (NSString *)documentId {
    return [self.gdpr documentId];
}

- (NSString *)documentVersion {
    return [self.gdpr documentVersion];
}

- (NSString *)documentDescription {
    return [self.gdpr documentDescription];
}

// MARK: - Private methods

- (SPTracker *)tracker {
    return self.serviceProvider.tracker;
}

- (SPGDPRConfigurationUpdate *)dirtyConfig {
    return self.serviceProvider.gdprConfigurationUpdate;
}

@end
