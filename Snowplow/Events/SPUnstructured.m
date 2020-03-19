//
//  SPUnstructured.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPUnstructured.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SPUnstructured {
    SPSelfDescribingJson * _eventData;
}

+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock {
    SPUnstructured* event = [SPUnstructured new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_eventData != nil) withMessage:@"EventData cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setEventData:(SPSelfDescribingJson *)eventData {
    _eventData = eventData;
}

// --- Public Methods

- (NSString *)schema {
    return _eventData.schema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSObject *data = [_eventData data];
    if ([data isKindOfClass:[NSDictionary<NSString *, NSObject *> class]]) {
        return data;
    }
    return nil;
}

/*
- (SPPayload *) getRenewed:(BOOL)encoding {
    SPPayload *payload = [super payload];
    [payload addValueToPayload:kSPEventUnstructured forKey:kSPEvent];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:kSPUnstructSchema forKey:kSPSchema];
    [dict setObject:[_eventData getAsDictionary] forKey:kSPData];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [payload addValueToPayload:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:kSPUnstructured];
    
    if (encoding) {
        NSMutableDictionary *dict = [NSMutableDictionary alloc] initWithDictionary:[payload getAsDictionary]];
        NSString *dataString = (NSString *)[dict valueForKey:kSPUnstructured];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedString = [data base64EncodedStringWithOptions:0];

        // We need URL safe with no padding. Since there is no built-in way to do this, we transform
        // the encoded payload to make it URL safe by replacing chars that are different in the URL-safe
        // alphabet. Namely, 62 is - instead of +, and 63 _ instead of /.
        // See: https://tools.ietf.org/html/rfc4648#section-5
        encodedString = [[encodedString stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
                         stringByReplacingOccurrencesOfString:@"+" withString:@"-"];

        // There is also no padding since the length is implicitly known.
        encodedString = [encodedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
        
        [payload addValueToPayload:encodedString forKey:kSPUnstructuredEncoded];
    }
    
    return payload;
}
 */

- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding {
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:kSPEventUnstructured forKey:kSPEvent];

    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:kSPUnstructSchema
                                                        andSelfDescribingJson:_eventData];

    [payload addDictionaryToPayload:[sdj getAsDictionary]
                 base64Encoded:encoding
               typeWhenEncoded:kSPUnstructuredEncoded
            typeWhenNotEncoded:kSPUnstructured];
    return [self addDefaultParamsToPayload:payload];
}

@end
