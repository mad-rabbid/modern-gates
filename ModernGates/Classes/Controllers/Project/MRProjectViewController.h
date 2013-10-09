#import <Foundation/Foundation.h>
#import "MRRootViewController.h"
#import "MRFormElementDelegate.h"

@class MRProject;


@interface MRProjectViewController : MRRootViewController<UITableViewDelegate, UITableViewDataSource, MRFormElementDelegate, UIAlertViewDelegate>

+ (id)controllerWithProject:(MRProject *)project;

@end