#import "MRFormElement.h"

@class MRFormCell;
@class MRFormTableView;
@class MRFormSection;
@protocol MRFormElementDelegate;

@protocol GTSRowDelegate <NSObject>
@required
- (MRFormCell *)getCellForTableView:(MRFormTableView *)tableView;
- (NSString *)cellReusableIdentifier;
@end

@interface MRFormRowElement : MRFormElement <GTSRowDelegate>

@property (nonatomic, weak) MRFormSection *section;
@property (nonatomic, weak) id<MRFormElementDelegate> delegate;

@property (nonatomic, copy) NSString *fetchKey;
@property (nonatomic, copy) NSString *groupKey;
@end


