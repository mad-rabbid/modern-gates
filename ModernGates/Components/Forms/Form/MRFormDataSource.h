#import <Foundation/Foundation.h>
#import "MRFormTableViewBaseDelegate.h"

@class MRForm;

@interface MRFormDataSource : MRFormTableViewBaseDelegate <UITableViewDataSource>

@property (nonatomic, strong) MRForm *form;

- (id)initWithTableView:(MRFormTableView *)tableView;
- (void)reloadForm;
@end
