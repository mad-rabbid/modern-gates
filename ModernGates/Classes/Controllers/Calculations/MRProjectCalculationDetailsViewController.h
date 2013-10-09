#import <Foundation/Foundation.h>
#import "MRViewController.h"

@class MRCalculation;
@class MRProject;


@interface MRProjectCalculationDetailsViewController : MRViewController<UIAlertViewDelegate>

@property (nonatomic, retain) MRProject *project;
@property (nonatomic, retain) MRCalculation *calculation;

@end