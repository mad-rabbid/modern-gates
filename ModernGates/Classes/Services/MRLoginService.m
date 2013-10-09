#import "MRLoginService.h"


@implementation MRLoginService {

}

+ (MRLoginService *)sharedInstance {
    static MRLoginService *_instance;
    dispatch_once_t once;
    dispatch_once(&once, ^() {
        _instance = [MRLoginService new];
    });
    return _instance;
}


@end