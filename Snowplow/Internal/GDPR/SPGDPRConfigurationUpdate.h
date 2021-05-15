//
//  SPGDPRConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPGDPRConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPGDPRConfigurationUpdate : SPGDPRConfiguration

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL gdprEdited;

@end

NS_ASSUME_NONNULL_END
