//
//  AirportDetail.m
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportDetail.h"

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
}
@end

@interface AirportDetail ()

- (void)queryLocation:(NSString*)airport;
- (void)plotPosition:(NSArray*)data;

@end

@implementation AirportDetail

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)viewDidAppear:(BOOL)animated
{
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    self.dataReturned = NO;
    [self.mapView setHidden:YES];
    [self queryLocation:singletonObj.airportName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryLocation:(NSString *)airport
{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&sensor=true&key=%@", [airport urlEncodeUsingEncoding:NSUTF8StringEncoding], GOOGLE_API_KEY];
    
    NSURL *requestURL = [NSURL URLWithString:url];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Processing";
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
    
    if(error)
    {
        NSLog(@"Danger Will Robinson, DANGER!");
    }
    
    NSArray *placesArray = [jsonData objectForKey:@"results"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    self.dataReturned = YES;
    [self.tableView reloadData];
    [self.mapView setHidden:NO];
    [self plotPosition:placesArray];
}

- (void)plotPosition:(NSArray *)data
{
    
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    for(id<MKAnnotation> annotation in self.mapView.annotations)
    {
        
        if([annotation isKindOfClass:[StandardMapPoint class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
        
    }
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int i = 0; i < [data count]; i++)
    {
        
        NSDictionary *place = [data objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *location = [geo objectForKey:@"location"];
        
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"formatted_address"];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSString *loppedStr = [vicinity substringToIndex:([vicinity length] - 15)];
        NSString *addr1 = [[NSString alloc] init];
        NSScanner *scanner = [NSScanner scannerWithString:loppedStr];
        [scanner scanUpToString:@"," intoString:&addr1];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", addr1, [loppedStr substringFromIndex:([addr1 length]+2)]];
        
        CLLocationCoordinate2D placeCoordinate;
        
        placeCoordinate.latitude = [[location objectForKey:@"lat"] doubleValue];
        placeCoordinate.longitude = [[location objectForKey:@"lng"] doubleValue];
        
        singletonObj.airportLocation = placeCoordinate;
        singletonObj.airportGoogleName = name;
        singletonObj.airportGoogleAddress = loppedStr;
        
        StandardMapPoint *mpObj = [[StandardMapPoint alloc] initWithName:name address:loppedStr coordinate:placeCoordinate ref:@""];
        
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
    
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    static NSString *identifier = @"MapPoint";
    
    if([annotation isKindOfClass:[StandardMapPoint class]])
    {
        
        MKPinAnnotationView *annView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(annView == nil)
        {
            annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            annView.annotation = annotation;
        }
        
        annView.enabled = YES;
        annView.canShowCallout = YES;
        annView.animatesDrop = YES;
        
        return annView;
        
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (self.dataReturned) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (self.dataReturned) ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Assign section headers
    if(section == 0)
    {
        AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
        return singletonObj.airportName;
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    if(indexPath.section == 0)
    {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.textLabel.text = @"Location:";
        
        return cell;
    }

    return NULL;
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}
@end
