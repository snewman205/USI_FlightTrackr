//
//  MapPoint.m
//  FlightTrackr
//
//  Created by Scott Newman on 10/21/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

@synthesize title, subtitle, coordinate;

- (id)initWithName:(NSString *)pinTitle address:(NSString *)pinSubtitle coordinate:(CLLocationCoordinate2D)pinCoordinate
{
    self = [super init];
    
    if(self)
    {
        self.coordinate = pinCoordinate;
        self.title = pinTitle;
        self.subtitle = pinSubtitle;
    }
    
    return self;
}

@end
