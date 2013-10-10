#import "MRFormLabelElement.h"

@implementation MRFormLabelElement

@synthesize label;

- (NSString *)cellReusableIdentifier {
    return @"MRFormLabelCell";
}

- (void)updateValue:(NSString *)value {
}

@end
