//
//  SPGDPRController.h
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
#import "SPGDPRConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GDPRController)
@protocol SPGDPRController <SPGDPRConfigurationProtocol>

/**
 * Whether the recorded GDPR context is enabled and will be attached as context.
 */
@property (nonatomic, readonly) BOOL isEnabled;

/**
 * Reset GDPR context to be sent with each event.
 * @param basisForProcessing GDPR Basis for processing.
 * @param documentId ID of a GDPR basis document.
 * @param documentVersion Version of the document.
 * @param documentDescription Description of the document.
 */
- (void)resetWithBasis:(SPGdprProcessingBasis)basisForProcessing
                             documentId:(nullable NSString *)documentId
                        documentVersion:(nullable NSString *)documentVersion
                    documentDescription:(nullable NSString *)documentDescription
NS_SWIFT_NAME(reset(basis:documentId:documentVersion:documentDescription:));

/**
 * Enable the GDPR context recorded.
 */
- (BOOL)enable;

/**
 * Disable the GDPR context recorded.
 */
- (void)disable;

@end

NS_ASSUME_NONNULL_END

