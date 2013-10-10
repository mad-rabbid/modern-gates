#import "MRFormEditableElement.h"

@implementation MRFormEditableElement

@synthesize text;

- (NSString *)cellReusableIdentifier {
    return @"MRFormEditableCell";
}

- (void)fetchValueIntoObject:(id)object {
    if (self.fetchKey) {
        NSString *key = self.groupKey ?: self.fetchKey;
        if (text.length) {
            [object setValue:self.text forKeyPath:key];
        }
    }
}

- (void)updateValue:(NSString *)value {
    self.text = value;
}
@end
