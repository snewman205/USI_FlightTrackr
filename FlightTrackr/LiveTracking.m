//
//  LiveTracking.m
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "LiveTracking.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end

@implementation UIImage (RotationMethods)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DEGREES_TO_RADIANS(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end

@interface LiveTracking ()

- (void)plotRoute;
- (void)plotEndpoints;

@end

@implementation LiveTracking

@synthesize mapView, locationManager;

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
    // Initalize variables
    [super viewDidLoad];
	
    self.returnedRouteData = [[NSArray alloc] init];
    self.waypoints = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Stop the timer since we are leaving the map view
    [self.timer invalidate];
    self.timer = nil;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    self.foundCraft = NO;
    
    // The user has selected a new flight, so we need to map the initial route
    if(singletonObj.didChangeFlight)
    {
        [self plotRoute];
    }
    
    if(self.timer == nil)
    {
        // The user has returned to check the status of the same flight - update the position on the map
        if(!singletonObj.didChangeFlight)
        {
            [self plotCraft];
        }
        
        // Since we're back in the map view, we need our timer running again
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(plotCraft) userInfo:nil repeats:YES];
    }
    
    singletonObj.didChangeFlight = NO;
}

- (void)plotRoute
{
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/DecodeFlightRoute?faFlightID=%@", singletonObj.faFlightID]];
    
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

- (void)dataFetched2:(NSData*)response
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSDictionary *allData = [jsonDict objectForKey:@"InFlightInfoResult"];
    CLLocationCoordinate2D coord;
    
    coord.latitude = [[allData valueForKey:@"latitude"] doubleValue];
    coord.longitude = [[allData valueForKey:@"longitude"] doubleValue];
    
    self.craftCurrentHeading = [[allData valueForKey:@"heading"] doubleValue];
    
    // Check to see if the craft has already been plotted ... if it has, simply update the coordinates.  If not, plot that shit!

    for (id<MKAnnotation> ann in self.mapView.annotations)
    {
        if ([ann isKindOfClass:[MapPointCraft class]])
        {
            NSLog(@"updating craft location");
            
            UIImage *craftIcon = [UIImage imageNamed:@"38-airplane.png"];
            UIImage *rotatedCraftIcon = [craftIcon imageRotatedByDegrees:self.craftCurrentHeading];
            MKAnnotationView* annView = [self.mapView viewForAnnotation:ann];
            
            ann.coordinate = coord;
            annView.image = [self imageWithImage:rotatedCraftIcon convertToSize:CGSizeMake(35, 37)];
            self.foundCraft = YES;
            
            break;
        }
    }
    
    if(!self.foundCraft)
    {
        // We still haven't found the bugger which means it doesn't exist ... we can change that.
        NSLog(@"mapping craft location");
        MapPointCraft *mpObj = [[MapPointCraft alloc] initWithCoord:coord];
        [self.mapView addAnnotation:mpObj];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    
}

- (void)dataFetched:(NSData*)response
{
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    
    NSDictionary *allData = [jsonDict objectForKey:@"DecodeFlightRouteResult"];
    
    self.returnedRouteData = [allData objectForKey:@"data"];
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int i = 0; i < [self.returnedRouteData count]; i++)
    {
        // Magical math to determine the region for the map
        NSDictionary *flightObj = [self.returnedRouteData objectAtIndex:i];
        CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:[[flightObj valueForKey:@"latitude"] doubleValue] longitude:[[flightObj valueForKey:@"longitude"] doubleValue]];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
        [self.waypoints addObject:currentLocation];
    }
    
    // Plot the flight path!
    NVPolylineAnnotation *annotation = [[NVPolylineAnnotation alloc] initWithPoints:self.waypoints mapView:self.mapView];
	[self.mapView addAnnotation:annotation];
    
    MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
    
    [self plotEndpoints];
    [self plotCraft];
    [self.mapView setRegion:region animated:YES];
    
}

- (void)plotCraft
{
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/InFlightInfo?ident=%@", singletonObj.flightIdent]];
    
    dispatch_async(kBgQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       [self performSelectorOnMainThread:@selector(dataFetched2:) withObject:data waitUntilDone:YES];
                   });
}

- (void)plotEndpoints
{
    // Plot the start & end points
    CLLocation *locA;
    CLLocation *locB;
    CLLocationCoordinate2D coordA;
    CLLocationCoordinate2D coordB;
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    
    locA = [self.waypoints objectAtIndex:0];
    coordA.latitude = locA.coordinate.latitude;
    coordA.longitude = locA.coordinate.longitude;
    
    locB = [self.waypoints objectAtIndex:([self.waypoints count] - 1)];
    coordB.latitude = locB.coordinate.latitude;
    coordB.longitude = locB.coordinate.longitude;
    
    MapPoint *mpObjA = [[MapPoint alloc] initWithName:singletonObj.originAirport address:singletonObj.originLocation coordinate:coordA];
    MapPoint *mpObjB = [[MapPoint alloc] initWithName:singletonObj.destinationAirport address:singletonObj.destinationLocation coordinate:coordB];
 
    [self.mapView addAnnotation:mpObjA];
    [self.mapView addAnnotation:mpObjB];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MapPoint";
    
    // Custom images for the annotations are set here
	if ([annotation isKindOfClass:[NVPolylineAnnotation class]]) {
		return [[NVPolylineAnnotationView alloc] initWithAnnotation:annotation mapView:self.mapView];
	}
    else if([annotation isKindOfClass:[MapPoint class]])
    {
        MKAnnotationView *annView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        UIImage *icon = [UIImage imageNamed:@"map_marker.png"];
        
        if(annView == nil)
        {
            annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annView.image = icon;
        }
        else
        {
            annView.annotation = annotation;
        }
        
        annView.enabled = YES;
        annView.canShowCallout = YES;
        
        return annView;
    }
    else if([annotation isKindOfClass:[MapPointCraft class]])
    {
        MKAnnotationView *annView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MapPointCraft"];
        UIImage *craftIcon = [UIImage imageNamed:@"38-airplane.png"];
        UIImage *rotatedCraftIcon = [craftIcon imageRotatedByDegrees:self.craftCurrentHeading];
        
        if(annView == nil)
        {
            annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapPointCraft"];
            annView.image = [self imageWithImage:rotatedCraftIcon convertToSize:CGSizeMake(35, 37)];
        }
        else
        {
            annView.annotation = annotation;
        }
        
        return annView;
    }
    
	return nil;
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
