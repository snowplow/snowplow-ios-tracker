//
//  SPGDPRController.m
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPGDPRController.h"

@interface SPGDPRController ()

@property (nonatomic, readwrite) SPGdprProcessingBasis basisForProcessing;
@property (nonatomic, readwrite) NSString *documentId;
@property (nonatomic, readwrite) NSString *documentVersion;
@property (nonatomic, readwrite) NSString *documentDescription;

@property SPTracker *tracker;

@end

@implementation SPGDPRController

@synthesize basisForProcessing;
@synthesize documentId;
@synthesize documentVersion;
@synthesize documentDescription;

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
    }
    return self;
}

// MARK: - Methods

- (void)resetWithBasis:(SPGdprProcessingBasis)basisForProcessing
            documentId:(NSString *)documentId
       documentVersion:(NSString *)documentVersion
   documentDescription:(NSString *)documentDescription
{
    self.basisForProcessing = basisForProcessing;
    self.documentId = documentId;
    self.documentVersion = documentVersion;
    self.documentDescription = documentDescription;
    [self.tracker setGdprContextWithBasis:basisForProcessing
                               documentId:documentId
                          documentVersion:documentVersion
                      documentDescription:documentDescription];
}

- (void)disable {
    [self.tracker disableGdprContext];
}

- (BOOL)enable {
    if (self.documentId && self.documentVersion && self.documentDescription) {
        [self.tracker enableGdprContextWithBasis:self.basisForProcessing
                                      documentId:self.documentId
                                 documentVersion:self.documentVersion
                             documentDescription:self.documentDescription];
        return YES;
    }
    return NO;
}

@end
