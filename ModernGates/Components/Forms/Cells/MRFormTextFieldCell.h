#import <UIKit/UIKit.h>
#import "MRFormCell.h"


@interface MRFormTextFieldCell : MRFormCell

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *buttonCalc;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
