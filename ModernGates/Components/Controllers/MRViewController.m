#import "MRViewController.h"

#define kTextOffset 8.0

@implementation MRViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    }
}

- (UIBarButtonItem *)menuBarButtonItem {
    return [MRViewController barButtonItemWithImage:[UIImage imageNamed:@"sidebar-icon-menu.png"] style:MRBarButtonTypeCommon target:self action:@selector(toggleSideMenuPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [MRViewController barButtonItemWithImage:[UIImage imageNamed:@"sidebar-icon-back.png"] style:MRBarButtonTypeBack target:self action:@selector(backButtonPressed:)];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image style:(MRBarButtonStyle)style target:(id)target action:(SEL)action {
    return [self barButtonItemWithStyle:style target:target action:action block:^(UIButton *button) {
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateHighlighted];
    }];
}

+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(MRBarButtonStyle)style target:(id)target action:(SEL)action {
    return [self barButtonItemWithStyle:style target:target action:action block:^(UIButton *button) {
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.minimumScaleFactor = 0.0;
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];

        CGSize size = [title sizeWithFont:button.titleLabel.font];
        button.frame = CGRectMake(0, 0, size.width + 2 * kTextOffset, 30);
    }];
}

+ (UIBarButtonItem *)barButtonItemWithStyle:(MRBarButtonStyle)style target:(id)target action:(SEL)action block:(void (^)(UIButton *button))block {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (style == MRBarButtonTypeCommon) ? 40 : 42, 30)];

    UIImage *backgroundImage = [UIImage imageNamed:(style == MRBarButtonTypeCommon) ? @"sidebar-button-normal.png" : @"sidebar-button-back.png"];
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, (style == MRBarButtonTypeCommon) ? 7 : 15, 10, 7)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    block(button);

    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
@end