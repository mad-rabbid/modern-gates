#import <AssetsLibrary/AssetsLibrary.h>
#import "MRProjectPhotoDetailViewController.h"
#import "UIViewController+MRTitleView.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@implementation MRProjectPhotoDetailViewController {
    __weak UIScrollView *_scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _scrollView = (UIScrollView *)self.view;
    _scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    _scrollView.maximumZoomScale = 2.0;
    [_scrollView setDelegate:self];
    [_scrollView setBouncesZoom:YES];

    ALAssetRepresentation *assetRepresentation = [self.asset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:UIImageOrientationUp];

    // add touch-sensitive image view to the scroll view
    TapDetectingImageView *imageView = [[TapDetectingImageView alloc] initWithImage:fullScreenImage];
    [imageView setDelegate:self];
    [imageView setTag:ZOOM_VIEW_TAG];
    [_scrollView setContentSize:[imageView frame].size];
    [_scrollView addSubview:imageView];

    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [_scrollView frame].size.width  / [imageView frame].size.width;
    [_scrollView setMinimumZoomScale:minimumScale];
    
    [_scrollView zoomToRect:CGRectMake(0.0, 0.0, imageView.frame.size.width, imageView.frame.size.height) animated:NO];

    self.navigationItem.rightBarButtonItem = [MRViewController barButtonItemWithTitle:NSLocalizedString(@"Закрыть", nil) style:MRBarButtonTypeCommon target:self action:@selector(didCloseButtonTouch:)];
    self.navigationTitle = @"Фотография";
}

- (void)didCloseButtonTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [(UIScrollView *)self.view viewWithTag:ZOOM_VIEW_TAG];
}


#pragma mark -
#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // single tap does nothing for now
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    UIScrollView *imageScrollView = (UIScrollView *)self.view;
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    UIScrollView *imageScrollView = (UIScrollView *)self.view;
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}


#pragma mark -
#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {

    CGRect zoomRect;

    UIScrollView *imageScrollView = (UIScrollView *)self.view;

    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;

    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);

    return zoomRect;
}


- (void)dealloc {
    self.asset = nil;
}
@end