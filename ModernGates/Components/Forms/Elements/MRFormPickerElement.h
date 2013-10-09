#import "MRFormEditableElement.h"
#import "MRFormPickerParser.h"

@interface MRFormPickerElement : MRFormEditableElement

@property (nonatomic, strong) NSArray *source;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *selectedIndices;
@property (nonatomic, strong) id<MRFormPickerParser> valueParser;

- (id)initWithItems:(NSArray *)items value:(NSString *)value;


@end
