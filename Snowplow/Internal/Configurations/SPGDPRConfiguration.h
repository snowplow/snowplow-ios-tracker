//
//  SPGDPRConfiguration.h
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

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"


typedef NS_ENUM(NSInteger, SPGdprProcessingBasis) {
    SPGdprProcessingBasisConsent = 0,
    SPGdprProcessingBasisContract = 1,
    SPGdprProcessingBasisLegalObligation = 2,
    SPGdprProcessingBasisVitalInterest = 3,
    SPGdprProcessingBasisPublicTask = 4,
    SPGdprProcessingBasisLegitimateInterests = 5
} NS_SWIFT_NAME(GDPRProcessingBasis);


NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GDPRConfigurationProtocol)
@protocol SPGDPRConfigurationProtocol

@property (nonatomic, readonly) SPGdprProcessingBasis basisForProcessing;
@property (nonatomic, readonly) NSString *documentId;
@property (nonatomic, readonly) NSString *documentVersion;
@property (nonatomic, readonly) NSString *documentDescription;

@end

NS_SWIFT_NAME(GDPRConfiguration)
@interface SPGDPRConfiguration : SPConfiguration <SPGDPRConfigurationProtocol>

- (instancetype)initWithBasis:(SPGdprProcessingBasis)basisForProcessing
                   documentId:(NSString *)documentId
              documentVersion:(NSString *)documentVersion
          documentDescription:(NSString *)documentDescription
NS_SWIFT_NAME(init(basis:documentId:documentVersion:documentDescription:));

@end

NS_ASSUME_NONNULL_END
