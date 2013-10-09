#import "MRProjectStatusPopupViewController.h"
#import "MRProjectsDao.h"
#import "MRProject.h"
#import "MRFormatters.h"
#import "UIView+MRDottedBackground.h"


@implementation MRProjectStatusPopupViewController {
    __weak IBOutlet UILabel *_labelFactoryId;
    __weak IBOutlet UILabel *_labelFactoryDate;
    __weak IBOutlet UILabel *_labelFactoryStatus;

    __weak IBOutlet UITextField *_textFieldFactoryId;
    __weak IBOutlet UITextField *_textFieldFactoryDate;
    __weak IBOutlet UITextView *_textFieldFactoryStatus;

    __weak IBOutlet UIButton *_saveButton;

    __strong UIDatePicker *_datePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view useDottedBackground];

    _labelFactoryId.text = NSLocalizedString(@"ID заказа", nil);
    _labelFactoryDate.text = NSLocalizedString(@"Дата заказа", nil);
    _labelFactoryStatus.text = NSLocalizedString(@"Статус заказа", nil);
    [_saveButton setTitle:NSLocalizedString(@"Изменить", nil) forState:UIControlStateNormal];

    _datePicker = [UIDatePicker new];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    [_datePicker addTarget:self action:@selector(didChangedDate:) forControlEvents:UIControlEventValueChanged];
    _textFieldFactoryDate.inputView = _datePicker;
	
	_textFieldFactoryId.text = self.project.factoryId;

    NSDate *date = (self.project.factoryDate) ? self.project.factoryDate : _datePicker.date;
	_textFieldFactoryDate.text = [[MRFormatters simpleDateFormatter] stringFromDate:date];

    if (self.project.factoryDate) {
	    _datePicker.date = self.project.factoryDate;
    }

	_textFieldFactoryStatus.text = self.project.factoryStatus;
}

- (void)didChangedDate:(UIDatePicker *)picker {
    _textFieldFactoryDate.text = [[MRFormatters simpleDateFormatter] stringFromDate:picker.date];
}

- (IBAction)didTouchSaveButton {
    self.project.factoryId = _textFieldFactoryId.text;
    self.project.factoryDate = (_textFieldFactoryDate.text) ? [[MRFormatters simpleDateFormatter] dateFromString:_textFieldFactoryDate.text] : nil;
    self.project.factoryStatus = _textFieldFactoryStatus.text;

    [[MRProjectsDao sharedInstance] updateProject:self.project];
}

- (void)didCloseButtonTouch:(id)sender {
    [self didTouchSaveButton];
    [super didCloseButtonTouch:sender];
}
@end