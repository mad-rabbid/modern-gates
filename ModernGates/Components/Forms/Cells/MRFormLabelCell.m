#import "MRFormLabelCell.h"
#import "MRFormLabelElement.h"
#import "MRFormElementDelegate.h"

@implementation MRFormLabelCell

@synthesize label = _label;
@synthesize element = _element;
@synthesize tableView = _tableViewHost;

- (void)updateCellForElement:(MRFormRowElement *)anElement andTableView:(MRFormTableView *)aTableView {
    self.element = anElement;
    self.tableView = aTableView;
    
    [self updateCellFromElement];
}

- (MRFormLabelElement *)labelElement {
    return (MRFormLabelElement *)self.element;
}

- (void)updateCellFromElement {
    self.label.text = self.labelElement.label;
    self.errorLabel.text = self.labelElement.errorText;
    self.errorLabel.hidden = !self.labelElement.errorText.length;
}

- (void)notifyAboutValueWasChanged {
	if ([self.element.delegate respondsToSelector:@selector(valueChangedForElement:)]) {
        [self.element.delegate valueChangedForElement:self.element];
    }
}

@end
