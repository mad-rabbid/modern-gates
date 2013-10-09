#import "MRCustomerCell.h"
#import "MRCustomer.h"


@implementation MRCustomerCell {
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelName;
    __weak IBOutlet UILabel *_labelAddress;
    __weak IBOutlet UILabel *_labelEmail;
}

- (void)awakeFromNib {
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-form-background.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-form-background.png"]];
    [self sendSubviewToBack:self.backgroundView];
}

- (void)updateFromVO:(MRCustomer *)vo {
    _labelTitle.text = vo.title;
    _labelName.text = vo.name;
    _labelAddress.text = vo.address;
    _labelEmail.text = vo.email;
}
@end