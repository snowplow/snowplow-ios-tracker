//
//  KiteValidationPair.h
//  Tests
//
//  Created by Sam Duke on 24/01/2014.
//
//

@import Foundation;

@interface KiteValidationPair : NSObject <NSCopying>
@property (nonatomic, readonly) NSObject<NSCopying>* left;
@property (nonatomic, readonly) NSObject<NSCopying>* right;
+ (instancetype) pairWithLeft:(NSObject<NSCopying> *)l right:(NSObject<NSCopying> *)r;
- (instancetype) initWithLeft:(NSObject<NSCopying> *)l right:(NSObject<NSCopying> *)r;

@end
