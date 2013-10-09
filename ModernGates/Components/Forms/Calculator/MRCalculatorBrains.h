#import <Foundation/Foundation.h>

@interface MRCalculatorBrains : NSObject

@property (nonatomic, readonly, strong) NSString *error;
@property (nonatomic, strong) NSDecimalNumber *operand;

- (NSDecimalNumber *)performOperation:(NSString *)operation;

@end
