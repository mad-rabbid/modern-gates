#import <Foundation/Foundation.h>

@class MRFormRowElement;

@protocol MRFormElementDelegate <NSObject>

- (void)valueChangedForElement:(MRFormRowElement *)element;

@end
