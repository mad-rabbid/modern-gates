#import "MRFormPickerElement.h"
#import "MRFormPickerSpacedParser.h"

@implementation MRFormPickerElement

@synthesize items = _items;
@synthesize valueParser = _valueParser;

@synthesize selectedIndices = _selectedIndices;

- (id)init {
	self = [super init];
    if (self) {
        self.valueParser = [MRFormPickerSpacedParser new];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items value:(NSString *)value {
	self = [self init];
    if (self) {
        _items = items;
		self.text = value;
    }
    return self;
}

- (NSString *)cellReusableIdentifier {
    return @"MRFormPickerCell";
}

- (void)fetchValueIntoObject:(id)object {
    if (self.fetchKey) {
        [object setValue:self.selectedIndices forKeyPath:self.fetchKey];
    }
}

@end
