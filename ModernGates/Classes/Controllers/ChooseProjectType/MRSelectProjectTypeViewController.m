#import "MRSelectProjectTypeViewController.h"
#import "MRProjectEngineHelper.h"
#import "UINavigationController+MRNavigationBar.h"
#import "UIViewController+MRTitleView.h"

@interface MRSelectProjectTypeViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation MRSelectProjectTypeViewController {

}

+ (UIViewController *)modalViewControllerWithBlock:(MRSelectProjectTypeCompletion)block {
    MRSelectProjectTypeViewController *controller = [MRSelectProjectTypeViewController new];
    controller.completionBlock = block;

    UINavigationController *navigationController = [UINavigationController controllerForViewController:controller];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    return navigationController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationTitle = NSLocalizedString(@"Выберите тип проекта", nil);

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor colorWithWhite:239.0 / 255.0 alpha:1.0];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];

    self.navigationItem.rightBarButtonItem = [MRViewController barButtonItemWithTitle:NSLocalizedString(@"Закрыть", nil)
                                                                                style:MRBarButtonTypeCommon
                                                                               target:self
                                                                               action:@selector(didTouchCloseButton:)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MRProjectEngineHelper sharedInstance].engines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kMGCellIdentifier = @"MGCellIdentifier";

    NSArray *engines = [MRProjectEngineHelper sharedInstance].engines;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMGCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMGCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
    }
    cell.textLabel.text = engines[indexPath.row][@"info"];
    return cell;
}

- (void)didTouchCloseButton:(id)sender {
    if (self.completionBlock) {
        self.completionBlock(YES, nil);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *engines = [MRProjectEngineHelper sharedInstance].engines;
    if (self.completionBlock) {
        self.completionBlock(NO, engines[indexPath.row][@"code"]);
    }
}


@end