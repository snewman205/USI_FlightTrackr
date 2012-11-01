//
//  AirportLocalPlaces.m
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportLocalPlaces.h"

@interface AirportLocalPlaces ()

- (void)queryLocations:(NSString*)googleType;
- (void)plotPositions:(NSArray*)data;

@end

@implementation AirportLocalPlaces

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
	// Do any additional setup after loading the view.
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)viewDidAppear:(BOOL)animated
{
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    if(![singletonObj.googleRef isEqualToString:@""])
    {
        [singletonObj saveValues];
        [self performSegueWithIdentifier:@"segueAirportLocalPlaceDetail" sender:self];
        return;
    }
    
    if(singletonObj.didChangeAirport)
    {
    
        CLLocationDegrees maxLat = -90;
        CLLocationDegrees maxLon = -180;
        CLLocationDegrees minLat = 90;
        CLLocationDegrees minLon = 180;
    
        for(id<MKAnnotation> annotation in self.mapView.annotations)
        {
        
            if([annotation isKindOfClass:[StandardMapPoint class]])
            {
                [self.mapView removeAnnotation:annotation];
            }
        
        }
    
        StandardMapPoint *mpObj = [[StandardMapPoint alloc] initWithName:singletonObj.airportGoogleName address:singletonObj.airportGoogleAddress coordinate:singletonObj.airportLocation ref:@""];
    
        [self.mapView addAnnotation:mpObj];
    
        CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:singletonObj.airportLocation.latitude longitude:singletonObj.airportLocation.longitude];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    
        MKCoordinateRegion region;
        region.center.latitude     = (maxLat + minLat) / 2;
        region.center.longitude    = (maxLon + minLon) / 2;
        region.span.latitudeDelta  = maxLat - minLat;
        region.span.longitudeDelta = maxLon - minLon;
    
        [self.mapView setRegion:region animated:YES];
        
    }
    
    singletonObj.didChangeAirport = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    singletonObj.googleRef = @"";
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    static NSString *identifier = @"MapPoint";
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    if([annotation isKindOfClass:[StandardMapPoint class]])
    {
        
        MKPinAnnotationView *annView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(annView == nil)
        {
            annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            if(![annView.annotation.title isEqualToString:singletonObj.airportGoogleName])
            {
                UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                
                [rightButton addTarget:self action:@selector(showDetails) forControlEvents:UIControlEventTouchUpInside];
                
                annView.rightCalloutAccessoryView = rightButton;
            }
            
            if([self.query isEqualToString:@"lodging"])
            {
                annView.pinColor = [self getColor:[[NSUserDefaults standardUserDefaults] valueForKey:@"hotel_pin_color"]];
            }
            else if([self.query isEqualToString:@"car_rental"])
            {
                annView.pinColor = [self getColor:[[NSUserDefaults standardUserDefaults] valueForKey:@"rental_pin_color"]];
            }
            else
            {
                annView.pinColor = MKPinAnnotationColorRed;
            }
        }
        else
        {
            if(![annView.annotation.title isEqualToString:singletonObj.airportGoogleName])
            {
                UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                
                [rightButton addTarget:self action:@selector(showDetails) forControlEvents:UIControlEventTouchUpInside];
                
                annView.rightCalloutAccessoryView = rightButton;
            }
            
            if([self.query isEqualToString:@"lodging"])
            {
                annView.pinColor = [self getColor:[[NSUserDefaults standardUserDefaults] valueForKey:@"hotel_pin_color"]];
            }
            else if([self.query isEqualToString:@"car_rental"])
            {
                annView.pinColor = [self getColor:[[NSUserDefaults standardUserDefaults] valueForKey:@"rental_pin_color"]];
            }
            else
            {
                annView.pinColor = MKPinAnnotationColorRed;
            }
            annView.annotation = annotation;
        }
        
        annView.enabled = YES;
        annView.canShowCallout = YES;
        annView.animatesDrop = YES;
        
        return annView;
        
    }
    
    return nil;
}
                   
- (MKPinAnnotationColor)getColor: (NSString*)color
{
    if([color isEqualToString:@"MKPinAnnotationColorGreen"])
    {
        return MKPinAnnotationColorGreen;
    }
    else if([color isEqualToString:@"MKPinAnnotationColorRed"])
    {
        return MKPinAnnotationColorRed;
    }
    else if([color isEqualToString:@"MKPinAnnotationColorPurple"])
    {
        return MKPinAnnotationColorPurple;
    }

    return MKPinAnnotationColorRed;
}

- (IBAction)barButtonPress:(id)sender
{
    UIBarButtonItem *buttonItem = (UIBarButtonItem*)sender;
    NSString *buttonTitle = [buttonItem.title lowercaseString];
    
    if([buttonTitle isEqualToString:@"hotels"])
    {
        [self.btnRentals setStyle:UIBarButtonItemStyleBordered];
        [self.btnHotels setStyle:UIBarButtonItemStyleDone];
        self.query = @"lodging";
        buttonTitle = @"lodging";
    }
    else
    {
        [self.btnRentals setStyle:UIBarButtonItemStyleDone];
        [self.btnHotels setStyle:UIBarButtonItemStyleBordered];
        self.query = @"car_rental";
        buttonTitle = @"car_rental";
    }
    
    [self queryLocations:buttonTitle];
}

- (void)queryLocations:(NSString *)googleType
{
    
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    float radius = [[[NSUserDefaults standardUserDefaults] valueForKey:@"radius"] floatValue];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", singletonObj.airportLocation.latitude, singletonObj.airportLocation.longitude, [NSString stringWithFormat:@"%f", radius], googleType, GOOGLE_API_KEY];
    
    NSURL *requestURL = [NSURL URLWithString:url];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Searching";
    hud.bottomText = @"Please wait...";
    [hud showInView:self.view];
    
    dispatch_async(kBgQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:requestURL];
                       [self performSelectorOnMainThread:@selector(dataFetched:) withObject:data waitUntilDone:YES];
                   });
    
}

- (void)dataFetched:(NSData*)response
{
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    if(error)
    {
        NSLog(@"Danger Will Robinson, DANGER!");
    }

    NSArray *places = [jsonData objectForKey:@"results"];
    singletonObj.localPlacesResults = places;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        
    [self plotPositions:places];

}

- (void)plotPositions:(NSArray *)data
{
 
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if([annotation isKindOfClass:[StandardMapPoint class]])
        {
            StandardMapPoint *mp = annotation;
            if(![mp.title isEqualToString:singletonObj.airportGoogleName])
            {
                [self.mapView removeAnnotation:annotation];
            }
        }
        
    }
    
    for(int i = 0; i < [data count]; i++)
    {
        
        NSDictionary *place = [data objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *location = [geo objectForKey:@"location"];
        
        NSString *name = [place objectForKey:@"name"];
        NSString *ref = [place objectForKey:@"reference"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        
        CLLocationCoordinate2D placeCoordinate;
        
        placeCoordinate.latitude = [[location objectForKey:@"lat"] doubleValue];
        placeCoordinate.longitude = [[location objectForKey:@"lng"] doubleValue];
        
        StandardMapPoint *mpObj = [[StandardMapPoint alloc] initWithName:name address:vicinity coordinate:placeCoordinate ref:ref];
        
        [self.mapView addAnnotation:mpObj];
        
        CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:placeCoordinate.latitude longitude:placeCoordinate.longitude];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
        
    }
    
    MKCoordinateRegion region;
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    [self.mapView setRegion:region animated:YES];
    [self.btnInfo setHidden:NO];
    
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    singletonObj.googleRef = singletonObj.googleRef;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDetails
{
    StandardMapPoint *mpObj = [[self.mapView selectedAnnotations] objectAtIndex:0];
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    singletonObj.googleRef = mpObj.googleRef;
    [singletonObj saveValues];
    [self performSegueWithIdentifier:@"segueAirportLocalPlaceDetail" sender:self];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setBtnInfo:nil];
    [self setBtnHotels:nil];
    [self setBtnRentals:nil];
    [super viewDidUnload];
}

@end
