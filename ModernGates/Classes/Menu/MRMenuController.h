#import <Foundation/Foundation.h>
#import "MRViewController.h"


@interface MRMenuController : MRViewController <UITableViewDataSource, UITableViewDelegate> {
@protected
    __weak IBOutlet UITableView *_tableView;
}

- (void)setContentViewController:(UIViewController *)controller;
- (void)setContentViewController:(UIViewController *)controller showSideBar:(BOOL)show;
@end