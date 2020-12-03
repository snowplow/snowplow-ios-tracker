//
//  SPGDPRConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
