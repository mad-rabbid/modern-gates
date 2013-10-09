#import "MRFormLabelElement.h"
#import "MRFormEditableElement.h"

@interface MRFormNumberElement : MRFormEditableElement

@property (nonatomic, strong) NSDecimalNumber *number;
@property (nonatomic, assign) NSInteger fractionDigits;

@end
