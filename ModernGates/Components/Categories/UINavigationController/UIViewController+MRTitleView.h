#import <Foundation/Foundation.h>

@interface UIViewController (MRTitleView)

- (void)setNavigationTitle:(NSString *)title;
- (void)setNavigationTitle:(NSString *)title width:(CGFloat)width;
- (NSString *)navigationTitle;
- (void)updateNavigationTitle:(NSString *)title;
@end