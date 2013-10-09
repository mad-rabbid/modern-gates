#import <Foundation/Foundation.h>
#import "MRPopupViewController.h"
#import "YMKAnnotation.h"
#import "YMKMapViewDelegate+Protocol.h"
#import "MRProjectPopupViewController.h"
#import "YMKDraggablePinAnnotationViewDelegate+Protocol.h"


@interface MRProjectMapViewController : MRProjectPopupViewController<YMKMapViewDelegate, YMKDraggablePinAnnotationViewDelegate>
@end