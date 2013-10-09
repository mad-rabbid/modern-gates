#import <Foundation/Foundation.h>
#import "MRPopupViewController.h"

typedef void (^MRProjectNewCalculationBlock)(BOOL isSuccess, NSDictionary *result);

@interface MRProjectNewCalculationViewController : MRViewController

@property(nonatomic, copy) MRProjectNewCalculationBlock block;
@property(nonatomic, strong) NSArray *form;
@property(nonatomic, strong) NSString *projectType;



@end