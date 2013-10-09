#import "MRFormTableViewBaseDelegate.h"
#import "MRFormTableView.h"

@implementation MRFormTableViewBaseDelegate

- (MRFormTableView *)convertToTableView:(UIView *)aTableView {
	assert([aTableView isKindOfClass:[MRFormTableView class]]);
	return (MRFormTableView *)aTableView;
}

@end
