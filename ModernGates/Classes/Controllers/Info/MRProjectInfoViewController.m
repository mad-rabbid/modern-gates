#import "MRProjectInfoViewController.h"
#import "MRProjectsDao.h"
#import "MRProject.h"
#import "MRConstants.h"
#import "UIView+MRDottedBackground.h"


@implementation MRProjectInfoViewController {
    __weak IBOutlet UILabel *_labelProjectName;
    __weak IBOutlet UILabel *_labelProjectAddress;

    __weak IBOutlet UITextField *_textFieldName;
    __weak IBOutlet UITextField *_textFieldAddress;
    __weak IBOutlet UITextView *_textViewDescription;

    __weak IBOutlet UIButton *_saveButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view useDottedBackground];
    _labelProjectName.text = NSLocalizedString(@"Наименование", nil);
    _labelProjectAddress.text = NSLocalizedString(@"Адрес объекта", nil);
    [_saveButton setTitle:NSLocalizedString(@"Изменить", nil) forState:UIControlStateNormal];
	
	_textFieldName.text = self.project.orderTitle;
	_textFieldAddress.text = self.project.orderAddress;
	_textViewDescription.text = self.project.orderDescription;
}

- (IBAction)didTouchSaveButton {
    self.project.orderTitle = _textFieldName.text;
    self.project.orderAddress = _textFieldAddress.text;
    self.project.orderDescription = _textViewDescription.text;
    [[MRProjectsDao sharedInstance] updateProject:self.project];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMRProjectSettingsWereChanged object:nil];
}

- (void)didCloseButtonTouch:(id)sender {
    [self didTouchSaveButton];
    [super didCloseButtonTouch:sender];
}
@end