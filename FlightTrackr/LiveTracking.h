//
//  LiveTracking.h
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FlightStatusSingleton.h"
#import "LGViewHUD.h"
#import "CSMapRouteLayerView.h"

@interface LiveTracking : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property CLLocationCoordinate2D currentCenter;
@property int currentDistance;
@property BOOL firstLaunch;
@property (strong, nonatomic) NSArray *returnedRouteData;
@property (strong, nonatomic) NSMutableArray *waypoints;
@property (strong, nonatomic) CSMapRouteLayerView *routeView;

@end
