#import "MRProjectPopupViewController.h"
#import "MRProject.h"


@implementation MRProjectPopupViewController {

}

- (id)initWithProject:(MRProject *)project block:(MRPopupViewControllerBlock)block {
    self = [super initWithBlock:block];
    if (self) {
        _project = project;
    }
    return self;
}

@end