#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MRProjectPhotosViewController.h"
#import "MRPhotoCollectionCell.h"
#import "UIView+MRDottedBackground.h"
#import "MRProject.h"
#import "MRPhoto.h"
#import "MRPhotosDao.h"
#import "MRProjectsDao.h"
#import "UINavigationController+MRNavigationBar.h"
#import "MRProjectPhotoDetailViewController.h"
#import "MPColorTools.h"

#define kMRPhotoSections 4

@implementation MRProjectPhotosViewController {
    __weak IBOutlet UICollectionView *_collectionView;
    __weak IBOutlet UIButton *_buttonAddPhoto;

    __strong UIImagePickerController *_cameraController;

    __strong ALAssetsLibrary *_library;
    __strong NSMutableArray *_assets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view useDottedBackground];
    _collectionView.backgroundColor = [UIColor clearColor];
    _library = [ALAssetsLibrary new];
    [self updateImages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)updateImages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                return;
            }

            NSMutableArray *unsortedAssets = [NSMutableArray new];

            group.assetsFilter = [ALAssetsFilter allPhotos];
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop1) {
                if (!asset) {
                    return;
                }

                NSLog(@"Photo: %@", asset.defaultRepresentation.filename);

                [self.project.photos enumerateObjectsUsingBlock:^(MRPhoto *photo, BOOL *stop2) {
                    if ([asset.defaultRepresentation.filename isEqualToString:photo.name]) {
                        [unsortedAssets addObject:asset];
                        *stop2 = YES;
                    }
                }];
            }];

            NSMutableArray *currentAssets = [NSMutableArray array];
            NSMutableArray *photosToDelete = [NSMutableArray array];
            [self.project.photos enumerateObjectsUsingBlock:^(MRPhoto *photo, BOOL *stop) {
                __block BOOL found = NO;
                [unsortedAssets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop1) {
                    if ([photo.name isEqualToString:asset.defaultRepresentation.filename]) {
                        [currentAssets addObject:asset];
                        found = YES;
                        *stop1 = YES;
                    }
                }];

                if (!found) {
                    [photosToDelete addObject:photo];
                }
            }];


            [photosToDelete enumerateObjectsUsingBlock:^(MRPhoto *photo, NSUInteger idx, BOOL *stop) {
                [[MRPhotosDao sharedInstance] deletePhotoWithName:photo.name];
            }];

            dispatch_sync(dispatch_get_main_queue(), ^{
                _assets = currentAssets;
                [_collectionView reloadData];
            });
        } failureBlock:nil];


    });


}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	MRPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(MRPhotoCollectionCell.class) forIndexPath:indexPath];
    if (indexPath.row < _assets.count) {
        ALAsset *asset = _assets[indexPath.row];

        CGImageRef thumbnailImageRef = [asset thumbnail];
        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        cell.image = thumbnail;
    } else {
        cell.image = nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRGB:0xff6600];
}
- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MRPhotos" bundle:nil];
    MRProjectPhotoDetailViewController *controller = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(MRProjectPhotoDetailViewController.class)];
    controller.asset = _assets[indexPath.row];
    UINavigationController *navigationController = [UINavigationController controllerForViewController:controller];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)didTouchAddPhotoButton {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _cameraController = nil;
}

- (BOOL)startCameraControllerFromViewController:(UIViewController *)controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {

    if (!([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || !delegate || !controller)) {
        return NO;
    }

    _cameraController = [[UIImagePickerController alloc] init];
    _cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;

    _cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    _cameraController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    //_cameraController.allowsEditing = YES;
    _cameraController.delegate = delegate;

    [controller presentViewController:_cameraController animated:YES completion:^{

    }];
    return YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        _cameraController = nil;
        [self updateImages];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;

    if (CFStringCompare((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];

        imageToSave = (editedImage) ? editedImage : originalImage;
        [_library writeImageToSavedPhotosAlbum:[imageToSave CGImage] orientation:(ALAssetOrientation)[imageToSave imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                NSLog(@"error");
            } else {
                NSLog(@"url %@", assetURL);
                [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [[MRPhotosDao sharedInstance] createPhotoWithName:asset.defaultRepresentation.filename project:self.project];
                    self.project = [[MRProjectsDao sharedInstance] projectWithDate:self.project.date];
                } failureBlock:nil];
            }
        }];
    }

    [self imagePickerControllerDidCancel:picker];

}
@end