#import "MRMainMenuProjectCell.h"


@implementation MRMainMenuProjectCell {
    __weak IBOutlet UILabel *_labelSubtitle;
}

- (void)setSubtitle:(NSString *)subtitle {
    _labelSubtitle.text = subtitle;
}

@end