#import "MRScriptingService.h"
#import "MRJSONHelper.h"
#import "MagicalRecord.h"


@implementation MRScriptingService {
    __strong UIWebView *_scriptingEngine;
    __strong MRScriptingServiceBlock _block;
}

- (id)initWithBlock:(MRScriptingServiceBlock)block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }

    return self;
}

- (void)load {
    _scriptingEngine = [[UIWebView alloc] initWithFrame:CGRectZero];
    _scriptingEngine.delegate = self;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    MRLog(@"Engine is initialized with error: %@", error.localizedDescription);
    if (_block) {
        _block(NO, self);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    MRLog(@"Engine is initialized successfully");
    if (_block) {
        _block(YES, self);
    }
}

- (id)executeScript:(NSString *)script {
    NSString *result = [_scriptingEngine stringByEvaluatingJavaScriptFromString:script];
    MRLog(@"Result is: %@", result);
    return result.length ? [MRJSONHelper objectFromJson:result] : nil;
}

@end