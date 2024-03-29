//
//  NVPolylineAnnotation.m
//  nvpolyline
//
//  Created by William Lachance on 10-03-31.
//  Inspired by code and ideas from Craig Spitzkoff and Nicolas Neubauer 2009.
//

#import "NVPolylineAnnotation.h"


@implementation NVPolylineAnnotation

@synthesize points = _points; 

-(id) initWithPoints:(NSMutableArray*) points mapView:(MKMapView *)mapView {
	self = [super init];
	
	_points = [[NSMutableArray alloc] initWithArray:points];
	_mapView = mapView;
		
	return self;
}

- (CLLocationCoordinate2D) coordinate {
	return [_mapView centerCoordinate];
}

@end
