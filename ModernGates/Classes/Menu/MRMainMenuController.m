#import "MRMainMenuController.h"
#import "MRMainMenuCell.h"
#import "MRMainMenuHeader.h"
#import "MRStoryboardLocator.h"
#import "MRProjectsDao.h"
#import "MRProject.h"
#import "UIViewController+MRTitleView.h"
#import "MRSettingsViewController.h"
#import "MRProjectViewController.h"
#import "MRJSONHelper.h"
#import "MRPreviewController.h"
#import "UIView+MRDottedBackground.h"
#import "MRMainMenuProjectCell.h"
#import "MRCustomer.h"
#import "MRConstants.h"
#import "MRSelectProjectTypeViewController.h"
#import "MRAppDelegate.h"
#import "MRCalculationsDao.h"
#import "MRCalculation.h"
#import "JSONKit.h"
#import "MRFormatters.h"


enum {
    kSectionNewProject = 0,
    kSectionProjects,
    kSectionContent,
    kSectionSettings,
    kSectionsNumber
} __unused;

@implementation MRMainMenuController {
    __strong NSArray *_projects;
    __strong NSArray *_documents;
    BOOL initialized;
}

+ (id)controller {
    MRMainMenuController *result = [MRStoryboardLocator.sharedInstance controllerFromStoryboard:kMRStoryboardMainMenu];
    return result;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reloadProjects];
    self.navigationTitle = NSLocalizedString(@"Главное меню", nil);

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView useDottedBackground];
    _documents = [MRJSONHelper objectFromJsonFile:@"content.json" bundle:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIfProjectSettingsWereChanged:) name:kMRProjectSettingsWereChanged object:nil];
}

- (void)handleIfProjectSettingsWereChanged:(NSNotification *)notification {
    [self reloadProjects];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!initialized) {
        initialized = YES;
        [self setContentViewController:[MRSettingsViewController controller] showSideBar:YES];
        [self selectSettingsOption];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _projects = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UIView *)tableView {
    return kSectionsNumber;
}

- (NSInteger)tableView:(UIView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSectionNewProject:
        case kSectionSettings:
            return 1;
        case kSectionProjects:
            return _projects.count;
        case kSectionContent:
            return _documents.count;
        default:
            return 0;
    };
}

- (void)appendWithComma:(NSMutableString *)builder string:(NSString *)string {
    if (builder.length && string.length) {
        [builder appendString:@", "];
    }

    if (string.length) {
        [builder appendString:string];
    }
}

- (NSString *)projectSubtitile:(MRProject *)project {
    NSMutableString *builder = [NSMutableString string];
    MRCustomer *customer = project.customer;
    if (customer) {
        [builder appendString:(customer.title.length ? customer.title : customer.name)];
    }

    NSDate *date = project.date;
    if (date) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd.MM.yyyy";
        [self appendWithComma:builder string:[formatter stringFromDate:date]];
    }

    NSArray *calculations = [[MRCalculationsDao sharedInstance] calculationsForProject:project];
    if (calculations.count) {
        NSData *data = ((MRCalculation *)calculations[0]).data;
        if (data.length) {
            NSDictionary *result = [data objectFromJSONData];
            NSNumber *price = result[@"base"];
            if (price) {
                [self appendWithComma:builder string:[NSString stringWithFormat:NSLocalizedString(@"%@ у.е", nil), [[MRFormatters currencyFormatter] stringFromNumber:price]]];
            }
        }
    }

    return builder;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRMainMenuCell *cell = (indexPath.section == kSectionProjects) ? [MRMainMenuProjectCell cellForTableView:tableView] :[MRMainMenuCell cellForTableView:tableView];
    switch (indexPath.section) {
        case kSectionProjects: {
            MRProject *project = _projects[indexPath.row];
            cell.title = project.orderTitle;

            NSString *subtitle = [self projectSubtitile:project];
            ((MRMainMenuProjectCell *)cell).subtitle = subtitle;
            break;
        }
        case kSectionNewProject:
            cell.title = NSLocalizedString(@"Новый проект", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case kSectionSettings:
            cell.title = NSLocalizedString(@"Настройки", nil);
            break;
        case kSectionContent:
            cell.title = NSLocalizedString(_documents[indexPath.row][@"name"], nil);
            break;
        default:
            break;
    }

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == kSectionProjects) ? 0 : tableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == kSectionProjects) {
        return nil;
    }

    MRMainMenuHeader *header = [MRMainMenuHeader headerWithHeight:tableView.sectionHeaderHeight];
    switch (section) {
        case kSectionNewProject:
            header.title = NSLocalizedString(@"Проекты", nil);
            break;
        case kSectionContent:
            header.title = NSLocalizedString(@"Материалы", nil);
            break;
        case kSectionSettings:
            header.title = NSLocalizedString(@"Установки", nil);
            break;
    }

    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSectionNewProject:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self selectProjectType];
            break;
        case kSectionProjects:
            [self showProject:_projects[indexPath.row]];
            break;
        case kSectionSettings: {
            [self setContentViewController:[MRSettingsViewController controller] showSideBar:NO];
            break;
        }
        case kSectionContent: {
            MRPreviewController *previewController = [MRPreviewController new];
            previewController.dataSource = self;
            previewController.delegate = self;

            previewController.currentPreviewItemIndex = 0;
            [self setContentViewController:previewController showSideBar:NO];
            break;
        }
        default: {
//            NSDictionary *dictionary = [MRScriptingService.sharedInstance formDictionary];
//            NSString *json = [MRScriptingService.sharedInstance jsonFromObject:dictionary[@"form"]];
//            json = [NSString stringWithFormat:@"(function() {\n\nvar form = %@;\n return yett.engine.update(form);\n\n})();", json];
//
//            NSDictionary *response = [MRScriptingService.sharedInstance callEngineWithScript:json];
            break;
        }
    }
}

- (BOOL)tableView:(UIView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == kSectionProjects);
}

- (void)tableView:(UIView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRProject *project = _projects[indexPath.row];
        [MRProjectsDao.sharedInstance deleteProjectWithDate:project.date];
        [self reloadProjects];
        [self performSelector:@selector(showSettings) withObject:nil afterDelay:0];
    }
}

- (void)selectProjectType {
    __weak MRMainMenuController *myself = self;
    UIViewController *controller = [MRSelectProjectTypeViewController modalViewControllerWithBlock:^(BOOL isCancelled, NSString *type) {
        [ApplicationDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            if (!isCancelled) {
                [myself createProject:type];
            }
        }];

    }];

    CGRect frame = controller.view.frame;
    [ApplicationDelegate.window.rootViewController presentViewController:controller animated:YES completion:^{

    }];
}
- (void)createProject:(NSString *)type {
    NSDate *date = [MRProjectsDao.sharedInstance createProjectWithType:type];
    [self reloadProjects];

    __block NSInteger index = -1;
    [_projects enumerateObjectsUsingBlock:^(MRProject *project, NSUInteger idx, BOOL *stop) {
        if ([date compare:project.date] == NSOrderedSame) {
            index = idx;
            *stop = YES;
        }
    }];

    if (index >= 0) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:kSectionProjects] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self showProject:_projects[index]];
    }
}

- (void)showProject:(MRProject *)project {
    [self setContentViewController:[MRProjectViewController controllerWithProject:project] showSideBar:NO];
}

- (void)reloadProjects {
    _projects = MRProjectsDao.sharedInstance.projects;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionProjects] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -
#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController {
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
}

- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index {
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    if (selectedIndexPath.section == kSectionContent) {
        return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:_documents[selectedIndexPath.row][@"file"] ofType:nil]];
    }

    return nil;
}

- (void)showSettings {
    [self setContentViewController:[MRSettingsViewController controller] showSideBar:YES];
    [self selectSettingsOption];
}

- (void)selectSettingsOption {
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

@end