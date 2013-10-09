#import "MREditCustomerViewController.h"
#import "MRCustomer.h"
#import "MRCustomersDao.h"
#import "UIView+MRDottedBackground.h"
#import "UIViewController+MRTitleView.h"


@implementation MREditCustomerViewController {
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelName;
    __weak IBOutlet UILabel *_labelAddress;
    __weak IBOutlet UILabel *_labelEmail;
    __weak IBOutlet UILabel *_labelPhone;

    __weak IBOutlet UIButton *_button;

    __weak IBOutlet UITextField *_textFieldTitle;
    __weak IBOutlet UITextField *_textFieldName;
    __weak IBOutlet UITextField *_textFieldAddress;
    __weak IBOutlet UITextField *_textFieldEmail;
    __weak IBOutlet UITextField *_textFieldPhone;
    __weak IBOutlet UITextView *_textViewInfo;

    BOOL _isNew;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLabels];

    if (!_customer) {
        _customer = [[MRCustomersDao sharedInstance] createCustomer];
        _textViewInfo.text = nil;
        _isNew = YES;
    }
    [self.view useDottedBackground];
    self.navigationTitle = NSLocalizedString(@"Редактирование карточки Заказчика", nil);
    _textFieldTitle.text = _customer.title;
    _textFieldName.text = _customer.name;
    _textFieldAddress.text = _customer.address;
    _textFieldEmail.text = _customer.email;
    _textFieldPhone.text = _customer.phone;
    _textViewInfo.text = _customer.info;
}

- (void)setupLabels {
    _labelTitle.text = NSLocalizedString(@"Наименование", nil);
    _labelName.text = NSLocalizedString(@"ФИО", nil);
    _labelAddress.text = NSLocalizedString(@"Адрес", nil);
    _labelEmail.text = NSLocalizedString(@"E-mail", nil);
    _labelPhone.text = NSLocalizedString(@"Телефон", nil);

    [_button.titleLabel setText:NSLocalizedString((_customer ? @"Изменить" : @"Создать"), nil)];
}

- (IBAction)didButtonTouch:(id)sender {
    _customer.title = _textFieldTitle.text;
    _customer.name = _textFieldName.text;
    _customer.address = _textFieldAddress.text;
    _customer.email = _textFieldEmail.text;
    _customer.phone = _textFieldPhone.text;
    _customer.info = _textViewInfo.text;
    [[MRCustomersDao sharedInstance] updateCustomer:_customer];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)backButtonPressed:(id)sender {
    [self didButtonTouch:nil];
    [super backButtonPressed:sender];
}

@end