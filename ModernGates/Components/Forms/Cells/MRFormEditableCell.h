#import "MRFormLabelCell.h"

@interface MRFormEditableCell : MRFormLabelCell <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textValue;

@end
