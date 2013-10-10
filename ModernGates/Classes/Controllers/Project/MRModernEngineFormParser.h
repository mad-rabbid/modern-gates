#import <Foundation/Foundation.h>

@class MRForm;
@protocol MRFormElementDelegate;


@interface MRModernEngineFormParser : NSObject

@property (nonatomic, weak) id<MRFormElementDelegate>delegate;
@property (nonatomic, strong, readonly) MRForm *form;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)parse;

@end