#import "MRFormNumberElement.h"

@implementation MRFormNumberElement

@synthesize number = _number;
@synthesize fractionDigits = _fractionDigits;

- (id)init {
	self = [super init];
	if (self) {
		_number = NSDecimalNumber.zero;
	}
	return self;
}

- (NSString *)cellReusableIdentifier {
    return @"MRFormNumberCell";
}

- (void)fetchValueIntoObject:(id)object {
    if (self.fetchKey) {
        [object setValue:self.number forKeyPath:self.fetchKey];
    }
}

- (void)updateValue:(NSString *)value {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:value];
    self.number = ![NSDecimalNumber.notANumber isEqualToNumber:number] ? number : nil;
}
@end
