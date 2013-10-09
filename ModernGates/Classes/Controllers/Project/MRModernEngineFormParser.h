#import <Foundation/Foundation.h>

@class MRForm;
@protocol MRFormElementDelegate;


@interface MRModernEngineFormParser : NSObject

@property (nonatomic, weak) id<MRFormElementDelegate>delegate;
@property (nonatomic, strong, readonly) MRForm *form;

- (NSDictionary *)formElements;
- (NSArray *)parseErrors;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)parse;

@end