#import <Foundation/Foundation.h>

typedef enum {
    MRBarButtonTypeCommon,
    MRBarButtonTypeBack
} MRBarButtonStyle;

@interface MRViewController : UIViewController

- (void)backButtonPressed:(id)sender;

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image style:(MRBarButtonStyle)style target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(MRBarButtonStyle)style target:(id)target action:(SEL)action;
@end