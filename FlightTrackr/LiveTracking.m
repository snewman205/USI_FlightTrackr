//
//  LiveTracking.m
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "LiveTracking.h"

#define GOOGLE_API_KEY @"AIzaSyDqUXBOcIY9fFw39wUgAOEtxsV7GiOCuA8"
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
	
    [self.mapView setShowsUserLocation:YES];
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
    
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&keyword=%@&sensor=true&key=%@", self.currentCenter.latitude, self.currentCenter.longitude, [NSString stringWithFormat:@"%i", self.currentDistance], singletonObj.originAirport, GOOGLE_API_KEY];
    
    NSURL *requestURL = [NSURL URLWithString:url];
    
    dispatch_async(kBgQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:requestURL];
                       [self performSelectorOnMainThread:@selector(dataFetched:) withObject:data waitUntilDone:YES];
                   });
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    MKMapRect mRect = self.mapView.visibleMapRect;
    
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    self.currentDistance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    self.currentCenter = self.mapView.centerCoordinate;
    
}

- (void)dataFetched:(NSData*)response
{
    NSError *error;
    
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    
    if(error)
    {
        NSLog(@"Error");
    }
    
    NSArray *placesArray = [jsonData objectForKey:@"results"];
    
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
