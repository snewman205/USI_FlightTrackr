//
//  MapPoint.h
//  FlightTrackr
//
//  Created by Scott Newman on 10/21/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)pinTitle address:(NSString*)pinSubtitle coordinate:(CLLocationCoordinate2D)pinCoordinate;

@end