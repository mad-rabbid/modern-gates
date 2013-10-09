#import <QuartzCore/QuartzCore.h>
#import "UIViewController+MRTitleView.h"

#define kDefaultTitleViewWitdh 200

@implementation UIViewController (MRTitleView)

- (void)setNavigationTitle:(NSString *)title {
    [self setNavigationTitle:title width:kDefaultTitleViewWitdh];
}

- (void)setNavigationTitle:(NSString *)title width:(CGFloat)width {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0];
    UILabel *newTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, self.navigationController.navigationBar.bounds.size.height)];
    newTitleView.backgroundColor = [UIColor clearColor];
    newTitleView.font = font;

    newTitleView.textColor = [UIColor whiteColor];
    newTitleView.textAlignment = NSTextAlignmentCenter;
    newTitleView.numberOfLines = 2;
    newTitleView.lineBreakMode = NSLineBreakByWordWrapping;

    CALayer *layer = newTitleView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(0, -1);
    layer.shadowRadius = 0.5f;
    layer.shadowOpacity = 0.5f;

    newTitleView.text = title;
    [newTitleView sizeToFit];
    CGRect frame = newTitleView.frame;
    frame.size.height = self.navigationController.navigationBar.bounds.size.height;
    newTitleView.frame = frame;
    self.navigationItem.titleView = newTitleView;
}

- (NSString *)navigationTitle {
    return ((UILabel *)self.navigationItem.titleView).text;
}

- (void)updateNavigationTitle:(NSString *)title {
    UILabel *newTitleView = ((UILabel *)self.navigationItem.titleView);
    if (!newTitleView) {
        [self setNavigationTitle:title];
        return;
    }

    newTitleView.text = title;
    [newTitleView sizeToFit];

    CGRect frame = newTitleView.frame;
    frame.size.height = self.navigationController.navigationBar.bounds.size.height;
    newTitleView.frame = frame;
}
@end