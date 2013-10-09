#import <Foundation/Foundation.h>
#import "MRFormElementDelegate.h"

@class MRFormSection;

@interface MRForm : NSObject

@property (nonatomic, strong) NSMutableArray *sections;

- (void)addSection:(MRFormSection *)section;
- (NSInteger)sectionsCount;

- (MRFormRowElement *)elementWithKey:(NSString *)key;
@end
