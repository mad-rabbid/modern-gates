#import <Foundation/Foundation.h>
#import "MRViewController.h"

typedef void (^MRPopupViewControllerBlock)();


@interface MRPopupViewController : MRViewController

@property (nonatomic, copy) MRPopupViewControllerBlock block;

- (id)initWithBlock:(MRPopupViewControllerBlock)block;

- (void)didCloseButtonTouch:(id)sender;
@end