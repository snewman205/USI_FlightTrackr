//
//  LocalPlacesObject.h
//  FlightTrackr
//
//  Created by Unbounded on 10/24/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocalPlacesObject : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *ref;
@property CLLocationCoordinate2D coord;
@property NSInteger sectionNumber;

@end
