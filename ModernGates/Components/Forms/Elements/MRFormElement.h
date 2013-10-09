#import <Foundation/Foundation.h>

@interface MRFormElement : NSObject

@property (nonatomic, assign, getter = isDisabled) BOOL disabled;
@property (nonatomic, assign, getter = isHidden) BOOL hidden;

- (void)fetchValueIntoObject:(id)object;

@end
