#import "MRFormEditableElement.h"

@interface MRFormPickerElement : MRFormEditableElement

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger selectedIndex;

- (NSString *)labelForItemAtIndex:(NSInteger)index;
- (NSString *)valueForItemAtIndex:(NSInteger)index;
@end
