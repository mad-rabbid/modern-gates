#import <Foundation/Foundation.h>
#import "MRFormTableViewBaseDelegate.h"

@class MRFormTableView;

@interface MRFormTableViewDelegate : MRFormTableViewBaseDelegate <UITableViewDelegate>

- (id)initWithTableView:(MRFormTableView *)aTableView;

@end
