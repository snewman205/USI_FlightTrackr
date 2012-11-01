//
//  StandardMapPoint.h
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StandardMapPoint : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *googleRef;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)pinTitle address:(NSString*)pinSubtitle coordinate:(CLLocationCoordinate2D)pinCoordinate ref:(NSString*)googleRef;

@end
