#import "MRFormBooleanElement.h"

@implementation MRFormBooleanElement

@synthesize on = _on;

- (NSString *)cellReusableIdentifier {
    return @"MRFormBooleanCell";
}

- (void)fetchValueIntoObject:(id)object {
    if (self.fetchKey) {
        [object setValue:[NSNumber numberWithBool:self.on] forKeyPath:self.fetchKey];
    }
}
@end
