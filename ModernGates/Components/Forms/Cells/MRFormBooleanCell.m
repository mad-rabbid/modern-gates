#import "MRFormBooleanCell.h"
#import "MRFormBooleanElement.h"

@implementation MRFormBooleanCell

@synthesize switchOn = _switchOn;

- (MRFormBooleanElement *)booleanElement {
    return (MRFormBooleanElement *)self.element;
}

- (void)updateCellFromElement {
    self.switchOn.on = self.booleanElement.isOn;
    [super updateCellFromElement];
}

- (IBAction)didSwitchValueChange {
    self.booleanElement.on = self.switchOn.isOn;
    [self notifyAboutValueWasChanged];
}

@end
