#import "MRFormEditableElement.h"

@implementation MRFormEditableElement

@synthesize text;

- (NSString *)cellReusableIdentifier {
    return @"MRFormEditableCell";
}

- (void)fetchValueIntoObject:(id)object {
    if (self.fetchKey) {
        [object setValue:self.text forKeyPath:self.fetchKey];
    }
}
@end
