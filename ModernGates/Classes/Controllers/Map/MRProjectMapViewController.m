#import <CoreLocation/CoreLocation.h>
#import "MRProjectMapViewController.h"
#import "YMKMapView.h"
#import "YMKConfiguration.h"
#import "YMKLocationFetcher.h"
#import "YMKPinAnnotationView.h"
#import "YMKDraggablePinAnnotationView.h"
#import "MRProject.h"
#import "MRProjectsDao.h"
#import "YMKUserLocation.h"


#define kMRYandexMapsApiKey @"0K1dOIwIDC43TAaxybPy869Ncuz64A3gyYkGZBfgi7XR~dliK5PPzZ-iQXes85RjRIRBHR~qAPZpsqzq8DBDW15zOc3wXb2--XIGH6EWl2A="

@interface PointAnnotation : NSObject <YMKDraggableAnnotation>

+ (id)pointAnnotation;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, assign) YMKMapCoordinate coordinate;

@end

@implementation PointAnnotation

+ (id)pointAnnotation {
    return [[[self class] alloc] init];
}

@end

@implementation MRProjectMapViewController {
    __weak IBOutlet YMKMapView *_mapView;
    __weak IBOutlet UIButton *_locateMeButton;
    __weak IBOutlet YMKLocationFetcher *_locationFetcher;
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;

    __strong PointAnnotation *_annotation;
}

- (void)dealloc {
    _mapView.delegate = nil;
    [self stopMonitoringLocationFetching];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupYandexMapKit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _mapView.delegate = nil;
}

- (void)setupYandexMapKit {
    YMKConfiguration.sharedInstance.apiKey = kMRYandexMapsApiKey;

    _mapView.showsUserLocation = YES;
    _mapView.showTraffic = NO;
    _mapView.delegate = self;

    
    if ([self.project.orderLatitude compare:NSDecimalNumber.zero] == NSOrderedSame ||
        [self.project.orderLongitude  compare:NSDecimalNumber.zero] == NSOrderedSame) {
            [_mapView setCenterCoordinate:YMKMapCoordinateMake(55.753699, 37.619001)
                              atZoomLevel:11
                                 animated:NO];
    }
    else {
        [_mapView setCenterCoordinate:YMKMapCoordinateMake([self.project.orderLatitude doubleValue],
                                                           [self.project.orderLongitude doubleValue])
                          atZoomLevel:11
                             animated:NO];
    }
    
    
    [self updateFetchingLocationUI];
    [self startMonitoringLocationFetching];
    [self configureAndInstallAnnotation];

}

#pragma mark - IBActions

- (IBAction)zoomPlusButtonTapped:(id)sender {
    [_mapView zoomIn];
}

- (IBAction)zoomMinusButtonTapped:(id)sender {
    [_mapView zoomOut];
}

- (IBAction)locateMeButtonTapped:(id)sender {
    [_locationFetcher acquireUserLocationFromMapView];
}

#pragma mark - Monitoring Location Fetching

- (void)startMonitoringLocationFetching {
    [_locationFetcher addObserver:self forKeyPath:@"fetchingLocation" options:0 context:NULL];
}

- (void)stopMonitoringLocationFetching {
    [_locationFetcher removeObserver:self forKeyPath:@"fetchingLocation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == _locationFetcher) && [keyPath isEqualToString:@"fetchingLocation"]) {
        [self updateFetchingLocationUI];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Handle Fetched Location

- (void)setupActivityIndicatorVisible:(BOOL)activityShouldBeVisible {
    if (activityShouldBeVisible) {
        _activityIndicator.hidden = NO;
        [_locateMeButton addSubview:_activityIndicator];
        _activityIndicator.frame = CGRectMake(floorf((CGRectGetWidth(_locateMeButton.bounds) - CGRectGetWidth(_activityIndicator.bounds)) / 2.0f),
                                                  floorf((CGRectGetHeight(_locateMeButton.bounds) - CGRectGetHeight(_activityIndicator.bounds)) / 2.0f),
                                                  CGRectGetWidth(_activityIndicator.bounds),
                                                  CGRectGetHeight(_activityIndicator.bounds));
    } else {
        _activityIndicator.hidden = YES;
        [_activityIndicator removeFromSuperview];
    }
}

- (void)setupLocateMeButtonForFetchingStatus:(BOOL)isFetchingLocation {
    if (isFetchingLocation) {
        [_locateMeButton setImage:nil forState:UIControlStateNormal];
        [_locateMeButton setImage:nil forState:UIControlStateHighlighted];
    } else {
        [_locateMeButton setImage:[UIImage imageNamed:@"LocateMe.png"] forState:UIControlStateNormal];
        [_locateMeButton setImage:[UIImage imageNamed:@"LocateMeHighlighted.png"] forState:UIControlStateHighlighted];
    }
}

- (void)updateFetchingLocationUI {
    [self setupActivityIndicatorVisible:_locationFetcher.fetchingLocation];
    [self setupLocateMeButtonForFetchingStatus:_locationFetcher.fetchingLocation];
}

#pragma mark - YMKLocationFetcherDelegate

- (void)locationFetcherDidFetchUserLocation:(YMKLocationFetcher *)locationFetcher {
    [self updateFetchingLocationUI];
    [self scrollToUserLocation];

    if ([self.project.orderLatitude compare:NSDecimalNumber.zero] == NSOrderedSame ||
                [self.project.orderLongitude  compare:NSDecimalNumber.zero] == NSOrderedSame) {

        self.project.orderLongitude = @(_mapView.userLocation.location.coordinate.longitude);
        self.project.orderLatitude = @(_mapView.userLocation.location.coordinate.latitude);

        [[MRProjectsDao sharedInstance] updateProject:self.project];
        self.project = [[MRProjectsDao sharedInstance] projectWithDate:self.project.date];
        [self configureAndInstallAnnotation];
    }
}

- (void)scrollToUserLocation {
    CLLocation *userLocation = _mapView.userLocation.location;
    [_mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

- (void)locationFetcher:(YMKLocationFetcher *)locationFetcher didFailWithError:(NSError *)error {
    [self updateFetchingLocationUI];
    [self notifyUserWithLocationFetchingError:error];
}

- (void)notifyUserWithLocationFetchingError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable To Fetch User Location", @"Alert title")
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss alert button title")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - YMKMapViewDelegate

- (YMKAnnotationView *)mapView:(YMKMapView *)aMapView viewForAnnotation:(id<YMKAnnotation>)anAnnotation {
    static NSString *identifier = @"pointAnnotation";
    YMKDraggablePinAnnotationView *view = (YMKDraggablePinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (view == nil) {
        view = [[YMKDraggablePinAnnotationView alloc] initWithAnnotation:_annotation reuseIdentifier:identifier];
        view.canShowCallout = YES;
        view.pinColor = YMKPinAnnotationColorBlue;
        view.delegate = self;
    }

    return view;
}

- (void)configureAndInstallAnnotation {
    if ([self.project.orderLatitude compare:NSDecimalNumber.zero] == NSOrderedSame ||
            [self.project.orderLongitude  compare:NSDecimalNumber.zero] == NSOrderedSame) {
        return;
    }

    _annotation = [PointAnnotation pointAnnotation];
    _annotation.coordinate = YMKMapCoordinateMake([self.project.orderLatitude doubleValue], [self.project.orderLongitude doubleValue]);
    _annotation.title = @"Перетащи меня!";

    [_mapView addAnnotation:_annotation];
    _mapView.selectedAnnotation = _annotation;
}

- (void)draggablePinAnnotationViewDidEndMoving:(YMKDraggablePinAnnotationView *)view {
    self.project.orderLongitude = @(view.annotation.coordinate.longitude);
    self.project.orderLatitude = @(view.annotation.coordinate.latitude);

    [[MRProjectsDao sharedInstance] updateProject:self.project];
    self.project = [[MRProjectsDao sharedInstance] projectWithDate:self.project.date];
}
@end