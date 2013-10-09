#import "MRFormCell.h"

@implementation MRFormCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-form-background.png"]];
    }
    return self;
}

- (void)updateCellFromElement {
}

@end
