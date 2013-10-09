#import <Foundation/Foundation.h>
#import "MRViewController.h"

typedef void (^MRSelectProjectTypeCompletion)(BOOL isCancelled, NSString *type);

@interface MRSelectProjectTypeViewController : MRViewController

@property (nonatomic, copy) MRSelectProjectTypeCompletion completionBlock;

+ (UIViewController *)modalViewControllerWithBlock:(MRSelectProjectTypeCompletion)block;
@end