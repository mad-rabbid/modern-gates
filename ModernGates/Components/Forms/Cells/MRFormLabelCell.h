#import "MRFormCell.h"

@class MRFormRowElement;
@class MRFormTableView;

@interface MRFormLabelCell : MRFormCell

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, weak) MRFormRowElement *element;
@property (nonatomic, weak) MRFormTableView *tableView;

- (void)updateCellForElement:(MRFormRowElement *)anElement andTableView:(MRFormTableView *)aTableView;
- (void)notifyAboutValueWasChanged;

@end
