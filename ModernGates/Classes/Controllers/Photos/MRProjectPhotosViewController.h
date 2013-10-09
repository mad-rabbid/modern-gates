#import <Foundation/Foundation.h>
#import "MRPopupViewController.h"
#import "MRProjectPopupViewController.h"


@interface MRProjectPhotosViewController : MRProjectPopupViewController<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end