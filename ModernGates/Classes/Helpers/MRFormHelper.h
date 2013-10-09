#import <Foundation/Foundation.h>

@protocol MRFormElementDelegate;
@class MRForm;
@class MRFormSection;


@interface MRFormHelper : NSObject
- (id)initWithSettings:(NSDictionary *)settings delegate:(id <MRFormElementDelegate>)delegate;

+ (id)helperWithSettings:(NSDictionary *)settings delegate:(id <MRFormElementDelegate>)delegate;

- (MRForm *)parseFormElements:(NSArray *)elements sectionName:(NSString *)sectionName formErrors:(NSDictionary *)formErrors errors:(NSMutableArray *)errors;
- (void)updateValuesFromFormSection:(MRFormSection *)section dictionary:(NSDictionary *)dictionary;
@end