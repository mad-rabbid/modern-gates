#import <Foundation/Foundation.h>

@class MRForm;
@protocol MRFormElementDelegate;


@interface MREngineFormHolder : NSObject

@property (nonatomic, weak) id<MRFormElementDelegate> delegate;
@property (nonatomic, strong, readonly) MRForm *form;

- (id)initWithProjectType:(NSString *)type;

- (void)template;
@end