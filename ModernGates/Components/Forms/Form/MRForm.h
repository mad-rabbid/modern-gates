#import <Foundation/Foundation.h>
#import "MRFormElementDelegate.h"

@class MRFormSection;
@class MRFormLabelElement;

@interface MRForm : NSObject

@property (nonatomic, strong) NSMutableArray *sections;

- (void)addSection:(MRFormSection *)section;
- (NSInteger)sectionsCount;

- (void)fetchValueIntoObject:(id)object;

- (MRFormRowElement *)elementWithKey:(NSString *)key;

- (void)enumerateElementsWithBlock:(BOOL (^)(MRFormSection *section, MRFormLabelElement *element))block;
@end
