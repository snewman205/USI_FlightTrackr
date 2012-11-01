//
//  AirportSingleton.h
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AirportSingleton : NSObject

@property (strong, nonatomic) NSString *airportIdent;
@property (strong, nonatomic) NSString *airportName;
@property (strong, nonatomic) NSString *airportCity;
@property (strong, nonatomic) NSString *airportState;
@property CLLocationCoordinate2D airportLocation;
@property (strong, nonatomic) NSString *airportGoogleName;
@property (strong, nonatomic) NSString *airportGoogleAddress;
@property (strong, nonatomic) NSString *googleRef;
@property (strong, nonatomic) NSArray *localPlacesResults;
@property (nonatomic) BOOL didChangeAirport;

+ (AirportSingleton *)sharedInstance;

- (void)saveValues;
- (NSString*)readValues;

@end
