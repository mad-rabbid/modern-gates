#import <Foundation/Foundation.h>
#import "MRPopupViewController.h"

@class MRProject;


@interface MRProjectPopupViewController : MRPopupViewController

@property (nonatomic, strong) MRProject *project;
@property (nonatomic, strong) NSArray *form;

- (id)initWithProject:(MRProject *)project block:(MRPopupViewControllerBlock)block;

@end