#import "MRStoryboardLocator.h"


@implementation MRStoryboardLocator {
    __strong NSMutableDictionary *_storyboards;
    __strong NSArray *_storyboardNames;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRStoryboardLocator *_sharedInstance;
    dispatch_once(&once, ^() {
        _sharedInstance = [MRStoryboardLocator new];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _storyboards = [NSMutableDictionary dictionary];
        _storyboardNames = @[
            @"MRMainMenu",
            @"MRProject",
            @"MRSettings"
        ];
    }

    return self;
}

- (UIStoryboard *)storyboardWithType:(MRStoryboardType)type {
    NSString *name = _storyboardNames[type];
    if (!_storyboards[name]) {
        @synchronized (_storyboards) {
            if (!_storyboards[name]) {
                _storyboards[name] = [UIStoryboard storyboardWithName:name bundle:nil];
            }
        }
    }
    return _storyboards[name];
}

- (id)controllerFromStoryboard:(MRStoryboardType)type {
    return [[self storyboardWithType:type] instantiateInitialViewController];
}
@end