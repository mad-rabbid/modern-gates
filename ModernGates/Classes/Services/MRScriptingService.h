#import <Foundation/Foundation.h>

@class MRScriptingService;

typedef void (^MRScriptingServiceBlock)(BOOL success, MRScriptingService *service);

@interface MRScriptingService : NSObject<UIWebViewDelegate>

- (id)initWithBlock:(MRScriptingServiceBlock)block;

- (void)load;
- (id)executeScript:(NSString *)script;


@end