#import "MRMainMenuHeader.h"

#define kHorizontalInset 15
#define kVerticalInset 2

#define kGradientTopColor 0x4d4d4d
#define kGradientBottomColor 0x2c2c2c

@implementation MRMainMenuHeader {
    __strong UILabel *_titleLabel;
}

+ (id)headerWithHeight:(CGFloat)height {
    return [[self alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, height)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControl];
    }

    return self;
}

- (void)setupControl {
    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

//    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
//    gradientLayer.startPoint = CGPointMake(0.5, 0);
//    gradientLayer.endPoint = CGPointMake(0.5, 1);
//    gradientLayer.frame = self.bounds;
//    gradientLayer.colors = @[
//        (__bridge id)[[UIColor colorWithRGB:kGradientTopColor] CGColor],
//        (__bridge id)[[UIColor colorWithRGB:kGradientBottomColor] CGColor]
//    ];
//
//    [self.layer addSublayer:gradientLayer];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, kHorizontalInset, kVerticalInset)];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    _titleLabel.autoresizingMask = self.autoresizingMask;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];

    _titleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    _titleLabel.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    _titleLabel.layer.shadowRadius = 1.5f;
    _titleLabel.layer.shadowOpacity = 0.8;
    _titleLabel.layer.masksToBounds = NO;

    [self addSubview:_titleLabel];

}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}
@end