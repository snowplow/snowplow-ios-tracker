//
//  SPConsentDocument.h
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

/// A consent document event.
NS_SWIFT_NAME(ConsentDocument)
@interface SPConsentDocument : NSObject

/// Identifier of the document.
@property (nonatomic, readonly) NSString *documentId;
/// Version of the document.
@property (nonatomic, readonly) NSString *version;
/// Name of the document.
@property (nonatomic, nullable) NSString *name;
/// Description of the document.
@property (nonatomic, nullable) NSString *documentDescription;

- (instancetype)init NS_UNAVAILABLE;

/**
 Create a consent document event.
 @param documentId identifier of the document.
 @param version version of the document.
 */
- (instancetype)initWithDocumentId:(NSString *)documentId version:(NSString *)version NS_SWIFT_NAME(init(documentId:version:));

/// Returns the payload.
- (SPSelfDescribingJson *)getPayload;

/// Name of the document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
/// Description of the document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentDescription)

@end

NS_ASSUME_NONNULL_END
