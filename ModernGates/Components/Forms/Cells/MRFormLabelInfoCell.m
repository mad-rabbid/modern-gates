#import "MRFormLabelInfoCell.h"
#import "MRFormLabelInfoElement.h"

@implementation MRFormLabelInfoCell

@synthesize labelInfo;

- (void)updateCellFromElement {
    self.labelInfo.text = ((MRFormLabelInfoElement *)self.element).info;
    [super updateCellFromElement];
}


@end
