#import "MRFormElement.h"

@class MRForm;
@class MRFormRowElement;

@interface MRFormSection : MRFormElement

@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, weak) MRForm *form;
@property (nonatomic, strong) NSString *title;

- (NSInteger) elementsCount;
- (NSInteger) visibleElementsCount;
- (void)addElement:(MRFormRowElement *)element;
- (MRFormRowElement *)elementAtIndex:(NSInteger)index;
- (NSInteger)visibleIndexOfElement:(MRFormRowElement *)element;
@end
