#import <UIKit/UIKit.h>

@class MRFormRowElement;
@class MRForm;

@interface MRFormTableView : UITableView

- (NSIndexPath *)indexForElement:(MRFormRowElement *)element;
- (UITableViewCell *)cellForElement:(MRFormRowElement *)element;

- (MRForm *)form;
- (void)setForm:(MRForm *)form;
- (void)reloadForm;
@end
