#import "MRMainMenuCell.h"


@implementation MRMainMenuCell {
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UIImageView *_imageView;
}

- (void)awakeFromNib {
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-menu-background.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-menu-background-selected.png"]];
    [self sendSubviewToBack:self.backgroundView];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setImageWithName:(NSString *)imageName {
    _imageView.image = [UIImage imageNamed:imageName];
}
@end