#import "MRFormElement.h"

@class MRFormTableView;

@protocol GTSFormBaseDelegate <NSObject>
- (MRFormTableView *)convertToTableView:(UIView *)aTableView;
@end

@interface MRFormTableViewBaseDelegate : MRFormElement <GTSFormBaseDelegate>

@end
