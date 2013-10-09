#import "MRFormRowElement.h"
#import "MRFormTableView.h"
#import "MRFormCell.h"

@implementation MRFormRowElement

@synthesize section;
@synthesize delegate;

@synthesize fetchKey;

- (NSString *)cellReusableIdentifier {
	return nil;
}

- (MRFormCell *)getCellForTableView:(MRFormTableView *)tableView {
	id cell = [tableView dequeueReusableCellWithIdentifier:[self cellReusableIdentifier]];
    
    if ([cell respondsToSelector:@selector(updateCellForElement:andTableView:)]) {
        [cell performSelector:@selector(updateCellForElement:andTableView:) withObject:self withObject:tableView];
    }
    
    return cell;
}


@end
