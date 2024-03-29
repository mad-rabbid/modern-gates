#import <MPColorTools/MPColorTools.h>
#import "UINavigationController+MRNavigationBar.h"

#define kHorizontalInset 7

@implementation UINavigationController (MRNavigationBar)

+ (UINavigationController *)controllerForViewController:(UIViewController *)rootViewController {
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self setupDefaultBackgrounds:controller];
    return controller;
}

+ (void)setupDefaultBackgrounds:(UINavigationController *)controller {
    UINavigationBar *bar = [controller navigationBar];


    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        [bar setTintColor:[UIColor colorWithRed:0.11 green:0.53 blue:0.93 alpha:1.0]];
        [bar setBackgroundImage:[self createResizeableImageWithName:@"navbar-orange.png"] forBarMetrics:UIBarMetricsDefault];
        [bar setBackgroundImage:[self createResizeableImageWithName:@"navbar-orange-landscape.png"] forBarMetrics:UIBarMetricsLandscapePhone];
    } else {
        bar.tintColor = [UIColor whiteColor];
        bar.barTintColor = [UIColor colorWithRGB:0xf08d32];
        bar.translucent = NO;
    }
}

+ (UIImage *)createResizeableImageWithName:(NSString *)name {

    UIImage *image = [UIImage imageNamed:name];
    CGFloat verticalInset = fabsf(image.size.height / 2 - 1);
    UIEdgeInsets insets = UIEdgeInsetsMake(verticalInset, kHorizontalInset, verticalInset, kHorizontalInset);

    return [image resizableImageWithCapInsets:insets];
}
@end