#import <MPColorTools/MPColorTools.h>
#import "MRProjectViewController.h"
#import "MRFormTableView.h"
#import "MRProject.h"
#import "MRJSONHelper.h"
#import "MRMainMenuCell.h"
#import "MRProjectEngineHelper.h"
#import "MRProjectsDao.h"
#import "MRStoryboardLocator.h"
#import "UIViewController+MRTitleView.h"
#import "MRForm.h"
#import "MRFormRowElement.h"
#import "MRProjectNewCalculationViewController.h"
#import "UINavigationController+MRNavigationBar.h"
#import "UIView+MRDottedBackground.h"
#import "MRMainMenuHeader.h"
#import "MRProjectCustomerViewController.h"
#import "MRProjectPhotosViewController.h"
#import "MRProjectMapViewController.h"
#import "MRProjectCalculationsViewController.h"
#import "MRProjectInfoViewController.h"
#import "MRProjectStatusPopupViewController.h"
#import "MRConstants.h"
#import "MRScriptingService.h"
#import "Toast+UIView.h"
#import "MREngineFormHolder.h"
#import "MRFormSection.h"

#define kWaitViewTag 1024
#define kWaitIndicatorTag 1025

enum MRProjectSections {
    kMRProjectSectionSettings = 0,
    kMRProjectSectionForm,
    kMRProjectSectionCalc,
    kMRProjectSectionsNumber
} __unused;

enum MRSectionSettingsRows {
    kMRSectionSettingsRowCustomer = 0,
    kMRSectionSettingsRowInfo,
    kMRSectionSettingsRowPhotos,
    kMRSectionSettingsRowMap,
    kMRSectionSettingsRowsNumber
} __unused;

enum MRSectionCalcRows {
    kMRSectionCalcRowCalculations = 0,
    kMRSectionCalcRowStatus,
    kMRSectionCalcRowsNumber
} __unused;

@implementation MRProjectViewController {
    __weak IBOutlet UITableView *_projectTableView;
    __weak IBOutlet MRFormTableView *_formTableView;

    __strong MRProject *_project;

    __strong MREngineFormHolder *_formHolder;
    __strong NSDictionary *_formErrors;

    __strong NSDictionary *_currentFormElements;
    __strong NSDictionary *_settings;

    __strong MRScriptingService *_service;

    __strong NSDictionary *_titles;
    __strong NSArray *_headers;

    NSUInteger _selectedSection;
}


+ (id)controllerWithProject:(MRProject *)project {
    MRProjectViewController *result = [MRStoryboardLocator.sharedInstance controllerFromStoryboard:kMRStoryboardProject];
    result.project = project;
    return result;
}

- (void)setProject:(MRProject *)project {
    _project = project;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (MRForm *)form {
    return _formHolder.form;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dropShadowFromFormTableView];
    [_projectTableView useDottedBackground];
    _formTableView.bounces = NO;

    _titles = @{
        @(kMRProjectSectionSettings) : @[@"Заказчик", @"Проект", @"Фотографии", @"Карта"],
        @(kMRProjectSectionCalc) : @[@"Расчеты", @"Статус"]
    };

    _headers = @[@"Проект", @"Данные", @"Заказ"];
    UIView *waitView = [[UIView alloc] initWithFrame:self.view.bounds];
    waitView.alpha = 0.0f;
    waitView.tag = kWaitViewTag;
    waitView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    waitView.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0xAA / 255.0];
    UIView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicatorView.center = waitView.center;
    activityIndicatorView.tag = kWaitIndicatorTag;
    [waitView addSubview:activityIndicatorView];

    [self.view addSubview:waitView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIfProjectSettingsWereChanged:) name:kMRProjectSettingsWereChanged object:nil];
}

- (void)handleIfProjectSettingsWereChanged:(NSNotification *)notification {
    _project = [[MRProjectsDao sharedInstance] projectWithDate:_project.date];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![[MRProjectEngineHelper new] doesEngineWithCodeExist:_project.type]) {
        [self performSelector:@selector(back) withObject:nil afterDelay:0];
        return;
    }

    _service = [MRScriptingService new];
    [_service load];
    [self loadProjectForm];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveProject];
}

- (void)saveProject {
    @try {
        // TODO: save the current project
        _project.data = [MRJSONHelper jsonDataFromObject:@{}];
        [MRProjectsDao.sharedInstance updateProject:_project];
    } @catch (NSException *exception) {
        MRLog(@"Exception: %@", exception);
    }
}

- (BOOL)loadProjectForm {
    _formHolder = [[MREngineFormHolder alloc] initWithProjectType:_project.type];
    _formHolder.delegate = self;

    if (_project.data) {
        //TODO: load saved data
    }

    if (!self.form) {
       [self performSelector:@selector(back) withObject:nil afterDelay:0];
       [self.view makeToast:NSLocalizedString(@"Невозможно загрузить справочник проекта", nil)];
       return NO;
    }

    [_projectTableView reloadData];
    [_projectTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedSection inSection:kMRProjectSectionForm]
                                  animated:NO
                            scrollPosition:UITableViewScrollPositionTop];
    [self showProjectSection:_selectedSection];
    return YES;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _titles = nil;
    _headers = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UIView *)tableView {
    return kMRProjectSectionsNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kMRProjectSectionSettings:
            return kMRSectionSettingsRowsNumber;
        case kMRProjectSectionForm:
            return ((MRFormSection *)self.form.sections[_selectedSection]).elements.count;
        case kMRProjectSectionCalc:
            return kMRSectionCalcRowsNumber;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRMainMenuCell *cell = [MRMainMenuCell cellForTableView:tableView];
    switch (indexPath.section) {
        case kMRProjectSectionCalc:
        case kMRProjectSectionSettings: {
            NSNumber *section = [NSNumber numberWithInt:indexPath.section];
            cell.title = NSLocalizedString(_titles[section][indexPath.row], nil);
            break;
        }
        case kMRProjectSectionForm: {
            MRFormSection *section = self.form.sections[indexPath.row];
            [cell setImageWithName:@"icon-complectation"];
            cell.title = section.title;
            break;
        }
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kMRProjectSectionCalc:
            [self didSelectRowInCalcSection:indexPath.row];
            break;
        case kMRProjectSectionSettings:
            [self didSelectRowInSettingsSection:indexPath.row];
            break;
        case kMRProjectSectionForm:
            [self showProjectSection:indexPath.row];
            return;
        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectRowInSettingsSection:(NSUInteger)row {
    switch (row) {
        case kMRSectionSettingsRowCustomer: {
            [self showPopup:MRProjectCustomerViewController.class title:@"Заказчик" initBlock:nil completionBlock:nil storyboard:@"MRCustomer"];
            break;
        }
        case kMRSectionSettingsRowInfo:
            [self showPopup:MRProjectInfoViewController.class title:@"Проект" initBlock:nil completionBlock:nil storyboard:@"MRProjectInfo"];
            break;
        case kMRSectionSettingsRowPhotos:
            [self showPopup:MRProjectPhotosViewController.class title:@"Фотографии" initBlock:nil completionBlock:nil storyboard:@"MRPhotos"];
            break;
        case kMRSectionSettingsRowMap:
            [self showPopup:MRProjectMapViewController.class title:@"Карта" initBlock:nil completionBlock:nil storyboard:@"MRMap"];
            break;
        default:
            break;
    }
}

- (void)didSelectRowInCalcSection:(NSUInteger)row {
    [self saveProject];

    switch (row) {
        case kMRSectionCalcRowCalculations: {
            __block MRProjectViewController *myself = self;
            [self showPopup:MRProjectCalculationsViewController.class title:@"Расчеты" initBlock:^(MRPopupViewController *controller) {
                MRProjectCalculationsViewController *calcController = (MRProjectCalculationsViewController *)controller;
                calcController.messagesBlock = ^(NSDictionary *messages) {
                    [myself updateFormWithErrorMessages:messages];
                    myself = nil;
                };
            } completionBlock:nil storyboard:@"MRCalculations"];
            break;
        }
        case kMRSectionCalcRowStatus:
            [self showPopup:MRProjectStatusPopupViewController.class title:@"Статус" initBlock:nil completionBlock:nil storyboard:@"MRStatus"];
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MRMainMenuHeader *header = [MRMainMenuHeader headerWithHeight:tableView.sectionHeaderHeight];
    header.title = NSLocalizedString(_headers[section], nil);
    return header;
}

- (void)showProjectSection:(NSInteger)section {
    [self updateNavigationTitle:[self.form.sections[section] title]];
    _selectedSection = section;
    [self updateForm];
}

- (void)updateProject {
    [MRProjectsDao.sharedInstance updateProject:_project];
}

- (void)updateForm {
    _formTableView.form = self.currentForm;
    [_formTableView reloadData];
}

- (void)dropShadowFromFormTableView {
    _formTableView.layer.masksToBounds = NO;
    _formTableView.layer.shadowColor = [UIColor blackColor].CGColor;
    _formTableView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _formTableView.layer.shadowOpacity = 1.0f;
    _formTableView.layer.shadowRadius = 2.5f;
    _formTableView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_formTableView.bounds].CGPath;
}

- (MRForm *)currentForm {
    MRForm *form = [MRForm new];
    [form addSection:self.form.sections[_selectedSection]];
    return form;
}

- (void)valueChangedForElement:(MRFormRowElement *)element {
    MRLog(@"Hurray! User was changed value for element %@", element.fetchKey);

    //TODO update form

    [_formTableView reloadData];

    MRFormRowElement *newElement = [_formTableView.form elementWithKey:element.fetchKey];
    if (newElement) {
        UITableViewCell *cell = [_formTableView cellForElement:newElement];
        if (cell) {
            [cell becomeFirstResponder];
        }
    }
}

- (void)updateFormWithErrorMessages:(NSDictionary *)messages {
    _formErrors = messages;
    [self updateForm];
}

- (void)showPopup:(Class)clazz title:(NSString *)title initBlock:(void (^)(MRPopupViewController *))initBlock completionBlock:(void (^)(MRPopupViewController *))completionBlock storyboard:(NSString *)storyboardName {
    __block UINavigationController *navigationController = [UINavigationController controllerForViewController:[UIViewController new]];
    MRPopupViewController *controller = nil;

    if (storyboardName.length) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        controller = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(clazz)];
    } else {
        controller = ((MRPopupViewController *)[clazz new]);
    }

    controller.block = ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (completionBlock) {
                completionBlock((MRPopupViewController *)navigationController.topViewController);
            }
            navigationController = nil;
        }];
    };

    controller.title = NSLocalizedString(title, nil);

    if ([controller isKindOfClass:MRProjectPopupViewController.class]) {
        MRProjectPopupViewController *projectPopupController = ((MRProjectPopupViewController *)controller);
        projectPopupController.project = _project;
        //projectPopupController.form = _form;
    }

    if (initBlock) {
        initBlock(controller);
    }
    navigationController.viewControllers = @[controller];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:navigationController animated:YES completion:nil];
}
@end