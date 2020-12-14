//
//  SPNetworkController.m
//  Snowplow
//
//  Created by Alex Benini on 14/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPNetworkController.h"

@interface SPNetworkController ()

@property SPEmitter *emitter;

@end


@implementation SPNetworkController {
    id<SPRequestCallback> _requestCallback;
}

- (instancetype)initWithEmitter:(SPEmitter *)emitter {
    if (self = [super init]) {
        self.emitter = emitter;
    }
    return self;
}

// MARK: - Properties

- (void)setEndpoint:(NSString *)endpoint {
    [self.emitter setUrlEndpoint:endpoint];
}

- (NSString *)endpoint {
    return [self.emitter urlEndpoint].absoluteString;
}

- (void)setMethod:(SPRequestOptions)method {
    [self.emitter setHttpMethod:method];
}

- (SPRequestOptions)method {
    return [self.emitter httpMethod];
}

- (void)setProtocol:(SPProtocol)protocol {
    [self.emitter setProtocol:protocol];
}

- (SPProtocol)protocol {
    return [self.emitter protocol];
}

- (void)setCustomPostPath:(NSString *)customPostPath {
    [self.emitter setCustomPostPath:customPostPath];
}

- (NSString *)customPostPath {
    return [self.emitter customPostPath];
}

@end
