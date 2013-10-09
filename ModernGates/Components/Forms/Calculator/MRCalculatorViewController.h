#import <UIKit/UIKit.h>

@protocol GTSCalculatorViewControllerDelegate;

@interface MRCalculatorViewController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel *display;
@property (nonatomic, copy) NSString *initialOperand;
@property (nonatomic, weak) id<GTSCalculatorViewControllerDelegate> delegate;

- (void)setInitialOperand:(NSString *)operand;
@end

@protocol GTSCalculatorViewControllerDelegate<NSObject>
@optional
- (void)calculatorViewController:(MRCalculatorViewController *)controller didEnterTouchWithResult:(NSString *)result;
@end