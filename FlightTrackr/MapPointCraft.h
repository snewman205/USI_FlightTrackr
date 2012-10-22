//
//  MapPointCraft.h
//  FlightTrackr
//
//  Created by Scott Newman on 10/21/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPointCraft : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithCoord:(CLLocationCoordinate2D)pinCoordinate;

@end
