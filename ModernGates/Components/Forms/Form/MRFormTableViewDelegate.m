#import "MRFormTableViewDelegate.h"
#import "MRFormTableView.h"

#define kHeaderHeight 36.0f

@implementation MRFormTableViewDelegate {
	__weak MRFormTableView *_owner;
}


- (id)initWithTableView:(MRFormTableView *)tableView {
    self = [super init];
    if (self) {
		_owner = tableView;
    }
    return self;
}

@end
