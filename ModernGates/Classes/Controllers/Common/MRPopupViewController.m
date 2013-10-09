#import "MRPopupViewController.h"
#import "UIViewController+MRTitleView.h"
#import "MagicalRecord.h"


@implementation MRPopupViewController {
}

- (id)initWithBlock:(MRPopupViewControllerBlock)block {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _block = [block copy];
    }

    return self;
}

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = [MRViewController barButtonItemWithTitle:NSLocalizedString(@"Закрыть", nil) style:MRBarButtonTypeCommon target:self action:@selector(didCloseButtonTouch:)];
    self.navigationTitle = self.title;

}

- (void)viewDidAppear:(BOOL)animated {
    MRLog(@"Bounds: %@", NSStringFromCGRect(self.view.frame));
}

- (void)didCloseButtonTouch:(id)sender {
    if (_block) {
        _block();
    }
}
@end