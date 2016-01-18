//
//  KiteValidationPair.m
//  Tests
//
//  Created by Sam Duke on 24/01/2014.
//
//

#import "KiteValidationPair.h"

@implementation KiteValidationPair

@synthesize left=_left;
@synthesize right=_right;

+ (instancetype)pairWithLeft:(NSObject<NSCopying>*)l right:(NSObject<NSCopying>*)r {
    return [[[self class] alloc] initWithLeft:l right:r];
}

- (instancetype)initWithLeft:(NSObject<NSCopying>*)l right:(NSObject<NSCopying>*)r {
    if (self = [super init]) {
        _left = [l copy];
        _right = [r copy];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithLeft:[self left] right:[self right]];
}
#pragma clang diagnostic pop

- (BOOL)isEqual:(id)obj
{
    if (![obj isKindOfClass:[KiteValidationPair class]])
        return NO;

    KiteValidationPair *other = (KiteValidationPair *)obj;
    BOOL isLeftEqual = (_left == other->_left ||
                        [_left isEqual:other->_left]);
    BOOL isRightEqual = (_right == other->_right ||
                         [_right isEqual:other->_right]);

    return (isLeftEqual && isRightEqual);
}

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

- (NSUInteger)hash
{
    return NSUINTROTATE([_left hash], NSUINT_BIT / 2) ^ [_right hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Left -> %@\nRight -> %@", _left, _right];
}

@end
