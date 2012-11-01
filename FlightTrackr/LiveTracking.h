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
#import "NVPolylineAnnotationView.h"
#import "MapPoint.h"
#import "MapPointCraft.h"
#import "AppDelegate.h"

@interface LiveTracking : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property CLLocationCoordinate2D currentCenter;
@property int currentDistance;
@property (nonatomic) BOOL foundCraft;
@property (strong, nonatomic) FlightStatusSingleton *singletonObj;
@property (strong, nonatomic) NSArray *returnedRouteData;
@property (strong, nonatomic) NSMutableArray *waypoints;
@property (nonatomic) float craftCurrentHeading;
@property (strong, nonatomic) NSTimer *timer;

@end
