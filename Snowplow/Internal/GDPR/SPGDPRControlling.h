//
//  SPGDPRControlling.h
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGDPRConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GDPRControlling)
@protocol SPGDPRControlling <SPGDPRConfigurationProtocol>

- (void)resetWithBasis:(SPGdprProcessingBasis)basisForProcessing
                             documentId:(NSString *)documentId
                        documentVersion:(NSString *)documentVersion
                    documentDescription:(NSString *)documentDescription
NS_SWIFT_NAME(reset(basis:documentId:documentVersion:documentDescription:));

- (BOOL)enable;
- (void)disable;

@end

NS_ASSUME_NONNULL_END

