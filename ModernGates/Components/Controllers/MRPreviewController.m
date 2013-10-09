#import "MRPreviewController.h"
#import "GHRevealViewController.h"
#import "MRViewController.h"
#import "MRAppDelegate.h"

typedef void (^MRPreviewControllerRevealBlock)();

@implementation MRPreviewController {
    __strong MRPreviewControllerRevealBlock _revealBlock;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [MRViewController barButtonItemWithImage:[UIImage imageNamed:@"sidebar-icon-menu.png"] style:MRBarButtonTypeCommon target:self action:@selector(revealSidebar)];
    }

    GHRevealViewController *revealViewController = ApplicationRevealViewController;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:revealViewController
                                                                                     action:@selector(dragContentView:)];
    panGesture.cancelsTouchesInView = YES;
    [self.navigationController.navigationBar addGestureRecognizer:panGesture];

    _revealBlock = ^() {
        [revealViewController toggleSidebar:!revealViewController.sidebarShowing
                               duration:kGHRevealSidebarDefaultAnimationDuration];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    GHRevealViewController *controller = ApplicationRevealViewController;
//    UIViewController *target = ((UINavigationController *)controller.contentViewController).viewControllers[0];
}

- (void)revealSidebar {
    _revealBlock();
}

@end