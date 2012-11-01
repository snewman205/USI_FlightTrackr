//
//  StandardMapPoint.m
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "StandardMapPoint.h"

@implementation StandardMapPoint

@synthesize title, subtitle, coordinate;

- (id)initWithName:(NSString *)pinTitle address:(NSString *)pinSubtitle coordinate:(CLLocationCoordinate2D)pinCoordinate ref:(NSString *)googleRef
{
    self = [super init];
    
    if(self)
    {
        self.coordinate = pinCoordinate;
        self.title = pinTitle;
        self.subtitle = pinSubtitle;
        self.googleRef = googleRef;
    }
    
    return self;
}

@end
