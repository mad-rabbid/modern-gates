#import "UIView+MRDottedBackground.h"


@implementation UIView (MRDottedBackground)

- (void)useDottedBackground {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu-background-pattern.png"]];
}

@end