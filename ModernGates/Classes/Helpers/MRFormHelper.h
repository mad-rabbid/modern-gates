#import <Foundation/Foundation.h>

@protocol MRFormElementDelegate;
@class MRForm;
@class MRFormSection;


@interface MRFormHelper : NSObject

- (id)initWithSections:(NSArray *)sections delegate:(id <MRFormElementDelegate>)delegate;
+ (id)helperWithSections:(NSArray *)sections delegate:(id <MRFormElementDelegate>)delegate;

- (MRForm *)parse;

@end