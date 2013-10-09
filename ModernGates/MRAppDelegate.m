#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "MRMainMenuController.h"
#import "UINavigationController+MRNavigationBar.h"
#import "MRProjectsDao.h"
#import "GHRevealViewController.h"
#import "GHRevealViewController+FastCreation.h"
#import "MKNetworkEngine.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@implementation MRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [MRProjectsDao.sharedInstance setup];
    [self setupNetworkEngine];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    UINavigationController *menuController = [UINavigationController controllerForViewController:[MRMainMenuController controller]];

    GHRevealViewController *revealViewController= [GHRevealViewController controller];
    revealViewController.sidebarViewController = menuController;

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = revealViewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)setupNetworkEngine {
    self.networkEngine = [[MKNetworkEngine alloc] initWithHostName:@"zend.eurobriz.ru" apiPath:@"igate" customHeaderFields:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // ttvvaa: пока логин не нужен
//    MRLoginViewController *controller = [MRLoginViewController new];
//
//    __weak MRAppDelegate *myself = self;
//    controller.block = ^(BOOL isSuccess, NSDictionary *dictionary) {
//        if (isSuccess) {
//            [MRLoginService sharedInstance].token = dictionary[@"id"] ?: @"";
//            [myself.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//        }
//    };
//
//    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

@end
