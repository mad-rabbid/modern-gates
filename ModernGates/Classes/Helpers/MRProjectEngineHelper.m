#import "MRProjectEngineHelper.h"
#import "MRJSONHelper.h"

@implementation MRProjectEngineHelper {
    __strong NSArray *_engines;
}

+ (MRProjectEngineHelper *)sharedInstance {
    static MRProjectEngineHelper *_instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^() {
        _instance = [MRProjectEngineHelper new];
    });
    return _instance;
}

- (NSArray *)engines {
    if (!_engines) {
        @synchronized (self) {
            if (!_engines) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"MRModernEngines.bundle/engines.json" ofType:nil];
                _engines = [MRJSONHelper objectFromJsonAtPath:path];
            }
        }
    }

    return _engines;
}

- (BOOL)doesEngineWithCodeExist:(NSString *)code {
    for (NSDictionary *engine in self.engines) {
        if ([engine[@"code"] isEqualToString:code]) {
            return YES;
        }
    }
    return NO;
}

@end