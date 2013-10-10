#import "MRFormPickerElement.h"

@implementation MRFormPickerElement

- (id)init {
	self = [super init];
    if (self) {
        self.selectedIndex = -1;
    }
    return self;
}

- (NSString *)cellReusableIdentifier {
    return @"MRFormPickerCell";
}

- (void)setItems:(NSArray *)items {
    _items = items;
    if (_items.count) {
        self.selectedIndex = 0;
    }
}

- (NSString *)labelForItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.items.count) {
        return nil;
    }
    return self.items[index][@"label"];
}

- (NSString *)valueForItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.items.count) {
        return nil;
    }

    NSString *result = self.items[index][@"value"];
    if (!result) {
        result = [self labelForItemAtIndex:index];
    }
    return result;
}

- (void)fetchValueIntoObject:(id)object {
    if (self.fetchKey) {
        [object setValue:[self valueForItemAtIndex:self.selectedIndex] forKeyPath:self.fetchKey];
    }
}

- (void)updateValue:(NSString *)value {
    for (NSInteger index = 0; index < self.items.count; index++) {
        if ([[self valueForItemAtIndex:index] isEqualToString:value]) {
            self.selectedIndex = index;
            break;
        }
    }
}
@end
