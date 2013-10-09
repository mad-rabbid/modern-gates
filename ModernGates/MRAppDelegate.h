#import <UIKit/UIKit.h>

@class MKNetworkEngine;

#define ApplicationDelegate ((MRAppDelegate *)UIApplication.sharedApplication.delegate)
#define ApplicationRootViewController (ApplicationDelegate.window.rootViewController)
#define ApplicationRevealViewController ((GHRevealViewController *)ApplicationRootViewController)

@interface MRAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) MKNetworkEngine *networkEngine;

@end
