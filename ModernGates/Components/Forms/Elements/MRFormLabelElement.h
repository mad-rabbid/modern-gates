#import "MRFormRowElement.h"

@interface MRFormLabelElement : MRFormRowElement

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *errorText;
@property (nonatomic, strong) NSDictionary *expressions;

- (void)updateValue:(NSString *)value;
@end
