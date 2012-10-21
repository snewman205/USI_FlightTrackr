//
//  LiveTracking.m
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "LiveTracking.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface LiveTracking ()

- (void)queryLocations;
- (void)plotPositions;

@end

@implementation LiveTracking

@synthesize mapView, locationManager, firstLaunch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.returnedRouteData = [[NSArray alloc] init];
    self.waypoints = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    self.firstLaunch = YES;
    [self queryLocations];
}

- (void)queryLocations
{
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://flightxml.flightaware.com/json/FlightXML2/DecodeFlightRoute?faFlightID=%@", singletonObj.faFlightID]];
    
    NSLog(@"url - %@", jsonURL);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Processing";
    hud.bottomText = @"Please wait...";
    [hud showInView:self.view];
    
    dispatch_async(kBgQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       [self performSelectorOnMainThread:@selector(dataFetched:) withObject:data waitUntilDone:YES];
                   });
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    
//    MKMapRect mRect = self.mapView.visibleMapRect;
//    
//    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
//    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
//    
//    self.currentDistance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
//    self.currentCenter = self.mapView.centerCoordinate;
//    
//}

- (void)dataFetched:(NSData*)response
{
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    
    NSDictionary *allData = [jsonDict objectForKey:@"DecodeFlightRouteResult"];
    
    self.returnedRouteData = [allData objectForKey:@"data"];
    
    for(int i = 0; i < [self.returnedRouteData count]; i++)
    {
        NSDictionary *flightObj = [self.returnedRouteData objectAtIndex:i];
        CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:[[flightObj valueForKey:@"latitude"] doubleValue] longitude:[[flightObj valueForKey:@"longitude"] doubleValue]];
        
        [self.waypoints addObject:currentLocation];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    
    self.routeView = [[CSMapRouteLayerView alloc] initWithRoute:self.waypoints mapView:self.mapView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}
@end
