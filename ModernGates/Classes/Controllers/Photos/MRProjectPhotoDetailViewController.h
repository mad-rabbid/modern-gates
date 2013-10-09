#import <Foundation/Foundation.h>
#import "TapDetectingImageView.h"
#import "MRViewController.h"


@interface MRProjectPhotoDetailViewController : MRViewController<UIScrollViewDelegate, TapDetectingImageViewDelegate>

@property (nonatomic, retain) ALAsset *asset;

@end