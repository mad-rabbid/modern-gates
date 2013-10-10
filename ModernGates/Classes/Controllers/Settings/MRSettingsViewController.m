#import "MRSettingsViewController.h"
#import "MRFormTableView.h"
#import "MRAbstractCell.h"
#import "MRMainMenuCell.h"
#import "MRForm.h"
#import "MRJSONHelper.h"
#import "UIView+MRDottedBackground.h"
#import "MRMainMenuHeader.h"
#import "MRFormHelper.h"
#import "MRStoryboardLocator.h"
#import "MRFormSection.h"
#import "MRFormLabelElement.h"
#import "UIViewController+MRTitleView.h"

#define kSettingsFormFile @"settings-form.json"

@implementation MRSettingsViewController {
    __weak IBOutlet UITableView *_projectTableView;
    __weak IBOutlet MRFormTableView *_formTableView;

    __strong MRForm *_form;
    __strong NSMutableDictionary *_defaultValues;
    NSUInteger _selectedSection;
}


+ (id)controller {
    return [MRStoryboardLocator.sharedInstance controllerFromStoryboard:kMRStoryboardSettings];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self dropShadowFromFormTableView];
    [_projectTableView useDottedBackground];
    self.navigationItem.rightBarButtonItem = [MRViewController barButtonItemWithTitle:NSLocalizedString(@"Сохранить", nil) style:MRBarButtonTypeCommon target:self action:@selector(didSaveButtonTouch:)];
}

- (void)didSaveButtonTouch:(id)sender {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    // TODO: Validate form

    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    [_form fetchValueIntoObject:values];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [settings setObject:value forKey:key];
    }];
    [settings synchronize];
}

- (void)setupFromSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [_form enumerateElementsWithBlock:^BOOL(MRFormSection *section, MRFormLabelElement *element) {
        NSString *value = [settings objectForKey:element.fetchKey];
        if (![value isKindOfClass:NSString.class] || !value.length) {
            value = _defaultValues[element.fetchKey];
            if (value) {
                [settings setObject:value forKey:element.fetchKey];
                [settings synchronize];
            }
        }

        [element updateValue:value];
        return NO;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *data = [MRJSONHelper objectFromJsonFile:kSettingsFormFile bundle:nil];

    MRFormHelper *formHelper = [MRFormHelper helperWithSections:data delegate:self];
    _form = [formHelper parse];
    _formTableView.form =_form;

    [self updateDefaultValuesWithSections:data];
    [self setupFromSettings];


    [_projectTableView reloadData];
    [_projectTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: _selectedSection]
                                 animated:NO
                           scrollPosition:UITableViewScrollPositionTop];
    [self showSettingsSection:_selectedSection];
}

- (void)updateDefaultValuesWithSections:(NSArray *)sections {
    _defaultValues = [NSMutableDictionary dictionary];
    for (NSDictionary *section in sections) {
        for (NSDictionary *element in section[@"elements"]) {
            NSString *value = element[@"value"] ? [element[@"value"] description] : nil;
            if (value) {
                _defaultValues[element[@"name"]] = value;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self didSaveButtonTouch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_form.sections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRMainMenuCell *cell = [MRMainMenuCell cellForTableView:tableView];
    cell.title = NSLocalizedString([_form.sections[indexPath.section] title], nil);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return tableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    MRMainMenuHeader *header = [MRMainMenuHeader headerWithHeight:tableView.sectionHeaderHeight];
    NSDictionary *dictionary = NSBundle.mainBundle.infoDictionary;
    header.title = [NSString stringWithFormat:@"Версия приложения: %@.%@",
                                      dictionary[@"CFBundleShortVersionString"],
                                      dictionary[@"CFBundleVersion"]];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showSettingsSection:indexPath.row];
}

- (void)showSettingsSection:(NSInteger)section {
    [self updateNavigationTitle:[_form.sections[section] title]];
    _selectedSection = section;
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

- (void)valueChangedForElement:(MRFormRowElement *)element {
}


@end
