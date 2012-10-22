//
//  MapPointCraft.m
//  FlightTrackr
//
//  Created by Scott Newman on 10/21/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "MapPointCraft.h"

@implementation MapPointCraft

@synthesize coordinate;

- (id)initWithCoord:(CLLocationCoordinate2D)pinCoordinate
{
    self = [super init];
    
    if(self)
    {
        self.coordinate = pinCoordinate;
    }
    
    return self;
}

@end
