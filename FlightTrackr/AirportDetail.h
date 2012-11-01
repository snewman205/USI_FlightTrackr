//
//  AirportDetail.h
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "AirportSingleton.h"
#import "LGViewHUD.h"
#import "StandardMapPoint.h"
#import "AppDelegate.h"

@interface AirportDetail : UITableViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL dataReturned;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
