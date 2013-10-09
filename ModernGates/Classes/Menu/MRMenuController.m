#import "MRMenuController.h"
#import "GHRevealViewController.h"
#import "MRAppDelegate.h"
#import "UINavigationController+MRNavigationBar.h"


@implementation MRMenuController

- (void)setContentViewController:(UIViewController *)controller {
    GHRevealViewController *revealViewController = ApplicationRevealViewController;
    UINavigationController *navigationController = [UINavigationController controllerForViewController:controller];
    revealViewController.contentViewController = navigationController;
}

- (void)setContentViewController:(UIViewController *)controller showSideBar:(BOOL)show {
    GHRevealViewController *revealViewController = ApplicationRevealViewController;

    if (!revealViewController.contentViewController) {
        UINavigationController *navigationController = [UINavigationController controllerForViewController:controller];
        revealViewController.contentViewController = navigationController;
    } else {
        UINavigationController *navController = (UINavigationController *)revealViewController.contentViewController;
        navController.viewControllers = @[controller];

    }

    [revealViewController toggleSidebar:show duration:kGHRevealSidebarDefaultAnimationDuration];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuFrame];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self setupMenuFrame];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self setupMenuFrame];
}

-(void)viewWillLayoutSubviews {
    [self setupMenuFrame];
}

- (void)setupMenuFrame {
    CGRect frame = self.navigationController.view.frame;
    frame.size.width = kGHRevealSidebarWidth;
    self.navigationController.wantsFullScreenLayout = NO;
    self.navigationController.view.frame = frame;

    self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
    [ApplicationRevealViewController.view layoutSubviews];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end