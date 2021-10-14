//
//  SPConsentWithdrawn.h
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
//  Copyright: Copyright © 2021 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/// A consent withdrawn event.
NS_SWIFT_NAME(ConsentWithdrawn)
@interface SPConsentWithdrawn : SPSelfDescribingAbstract

/// Consent to all.
@property (nonatomic) BOOL all;
/// Identifier of the first document.
@property (nonatomic, nullable) NSString *documentId;
/// Version of the first document.
@property (nonatomic, nullable) NSString *version;
/// Name of the first document.
@property (nonatomic, nullable) NSString *name;
/// Description of the first document.
@property (nonatomic, nullable) NSString *documentDescription;
/// Other documents.
@property (nonatomic, nullable) NSArray<SPSelfDescribingJson *> *documents;

/// Retuns the full list of attached documents.
- (NSArray<SPSelfDescribingJson *> *)getDocuments;

/// Consent to all.
SP_BUILDER_DECLARE(BOOL, all)
/// Identifier of the first document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentId)
/// Version of the first document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, version)
/// Name of the first document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
/// Description of the first document.
SP_BUILDER_DECLARE_NULLABLE(NSString *, documentDescription)
/// Other documents.
SP_BUILDER_DECLARE_NULLABLE(NSArray<SPSelfDescribingJson *> *, documents)

@end

NS_ASSUME_NONNULL_END
