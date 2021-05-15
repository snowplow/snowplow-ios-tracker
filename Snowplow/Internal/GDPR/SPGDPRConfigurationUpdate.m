//
//  SPGDPRConfigurationUpdate.m
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPGDPRConfigurationUpdate.h"

@implementation SPGDPRConfigurationUpdate

SP_DIRTY_GETTER(SPGdprProcessingBasis, basisForProcessing)
SP_DIRTY_GETTER(NSString *, documentId)
SP_DIRTY_GETTER(NSString *, documentVersion)
SP_DIRTY_GETTER(NSString *, documentDescription)

// Private methods

- (BOOL)basisForProcessingUpdated { return self.gdprUpdated; }
- (BOOL)documentIdUpdated { return self.gdprUpdated; }
- (BOOL)documentVersionUpdated { return self.gdprUpdated; }
- (BOOL)documentDescriptionUpdated { return self.gdprUpdated; }

@end
