#import "GHRevealViewController+FastCreation.h"

@implementation GHRevealViewController (FastCreation)

+ (GHRevealViewController *)controller {
    GHRevealViewController *controller = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
    controller.view.backgroundColor = [UIColor clearColor];
    return controller;
}
@end