//
//  AirportLocalPlaces.h
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "StandardMapPoint.h"
#import "AirportSingleton.h"
#import "LGViewHUD.h"
#import "AirportLocalPlacesList.h"
#import "AppDelegate.h"

@interface AirportLocalPlaces : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property int currentDistance;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) IBOutlet UIButton *btnInfo;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnRentals;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnHotels;

- (IBAction)barButtonPress:(id)sender;

@end
