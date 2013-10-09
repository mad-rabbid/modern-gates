#import <Foundation/Foundation.h>
#import "MRViewController.h"

#define kMGButtonLoginHeight 40

typedef void (^LoginViewCompletionBlock)(BOOL isSuccess, NSDictionary *dictionary);

@interface MRLoginViewController : MRViewController

@property (nonatomic, copy) LoginViewCompletionBlock block;

@end