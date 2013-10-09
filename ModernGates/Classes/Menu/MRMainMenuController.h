#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
#import "MRMenuController.h"


@interface MRMainMenuController : MRMenuController<QLPreviewControllerDataSource, QLPreviewControllerDelegate>

+ (id)controller;

@end