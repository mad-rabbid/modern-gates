#import <QuartzCore/QuartzCore.h>
#import "MRSettingsViewController.h"
#import "MRFormTableView.h"
#import "MRStoryboardLocator.h"
#import "UIViewController+MRTitleView.h"
#import "MRAbstractCell.h"
#import "MRMainMenuCell.h"
#import "MRFormHelper.h"
#import "MRForm.h"
#import "MRJSONHelper.h"
#import "UIView+MRDottedBackground.h"
#import "MRMainMenuHeader.h"
#import "MagicalRecord.h"

#define kSettingsFormFile @"settings-form.json"

@implementation MRSettingsViewController {
    __weak IBOutlet UITableView *_projectTableView;
    __weak IBOutlet MRFormTableView *_formTableView;
    __strong NSDictionary *_currentFormElements;
    __strong NSArray *_form;
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
    [self updateDataFromTableView];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    [self.currentElements enumerateObjectsUsingBlock:^(NSDictionary *element, NSUInteger idx, BOOL *stop) {
        NSString *value = element[@"value"];
        if (!value.length) {
            return;
        }

        NSString *name = element[@"name"];
        NSString *pattern = element[@"regexp"];
        if (pattern.length) {
            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
            if (expression && ![expression numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)]) {
                MRLog(@"Bad value %@ was detected for element with name %@", value, name);
                return;
            }
        }

        [settings setObject:value forKey:name];
    }];

    [settings synchronize];
}

- (void)setupFromSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [self.currentElements enumerateObjectsUsingBlock:^(NSMutableDictionary *element, NSUInteger idx, BOOL *stop) {
        NSString *name = element[@"name"];
        NSString *value = [settings objectForKey:name];
        if (value && [value isKindOfClass:NSString.class] && value.length) {
            element[@"value"] = value;
        } else {
            value = element[@"value"];
            if (value && [value isKindOfClass:NSString.class] && value.length) {
                [settings setObject:value forKey:name];
                [settings synchronize];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _form = [[MRJSONHelper objectFromJsonFile:kSettingsFormFile bundle:nil] mutableCopy];

    [self setupFromSettings];
    _formTableView.form = self.formData;

    [_projectTableView reloadData];
    if (_form.count) {
        [_projectTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: _selectedSection]
                                     animated:NO
                               scrollPosition:UITableViewScrollPositionTop];
        [self showSettingsSection:_selectedSection];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self updateDataFromTableView];

    [self didSaveButtonTouch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _form.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRMainMenuCell *cell = [MRMainMenuCell cellForTableView:tableView];
    cell.title = NSLocalizedString(_form[indexPath.row][@"label"], nil);
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
    [self updateNavigationTitle:_form[section][@"label"]];
    _selectedSection = section;

    if (_formTableView.form) {
        [self updateDataFromTableView];
    }

    if (!_formTableView.form) {
        [self valueChangedForElement:nil];
    } else {
        [self updateForm];
    }
}

- (void)updateForm {
    _formTableView.form = self.formData;
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

- (NSArray *)currentElements {
    return _form[_selectedSection][@"elements"];
}

- (void)updateDataFromTableView {
    MRFormHelper *helper = [MRFormHelper helperWithSettings:nil delegate:self];
    [helper updateValuesFromFormSection:_formTableView.form.sections[0] dictionary:_currentFormElements];
}

- (MRForm *)formData {
    MRFormHelper *helper = [MRFormHelper helperWithSettings:nil delegate:self];

    NSMutableArray *errors = [NSMutableArray array];
    NSArray *elements = self.currentElements;

    NSMutableDictionary *currentFormElements = [NSMutableDictionary dictionaryWithCapacity:elements.count];
    [elements enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
        currentFormElements[dictionary[@"name"]] = dictionary;
    }];
    _currentFormElements = currentFormElements;

    return [helper parseFormElements:elements sectionName: nil formErrors:nil errors:errors];
}

- (void)valueChangedForElement:(MRFormRowElement *)element {
}


@end
