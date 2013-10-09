#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "MRPhotoCollectionCell.h"


@implementation MRPhotoCollectionCell {
    __strong IBOutlet UIImageView *_imageView;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;

    if (!image) {
        self.backgroundColor = [UIColor clearColor];
        return;
    }
    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.layer.shadowRadius = 0.5f;
    self.layer.shadowOpacity = 0.5f;

    CGSize imageSize = image.size;
    CGSize size = CGRectInset(self.bounds, 5.0, 5.0).size;

    BOOL isPortrait = imageSize.height > imageSize.width;
    CGFloat factor = ((isPortrait) ? size.height / imageSize.height : size.width / imageSize.width);

    CGRect bounds = _imageView.bounds;
    bounds.size = CGSizeMake(imageSize.width * factor, imageSize.height * factor);
    _imageView.bounds = bounds;
    _imageView.center = _imageView.superview.center;
}
@end