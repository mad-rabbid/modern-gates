#import <Foundation/Foundation.h>
#import "MRFormElementDelegate.h"
#import "MRRootViewController.h"

@interface MRSettingsViewController : MRRootViewController<UITableViewDelegate, UITableViewDataSource, MRFormElementDelegate>

+ (id)controller;

@end