#import <Foundation/Foundation.h>

typedef enum {
    kMRStoryboardMainMenu = 0,
    kMRStoryboardProject,
    kMRStoryboardSettings

} MRStoryboardType;

@interface MRStoryboardLocator : NSObject

+ (MRStoryboardLocator *)sharedInstance;

- (id)controllerFromStoryboard:(MRStoryboardType)type;
@end