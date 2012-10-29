//
//  AirportSelectorResultsObj.h
//  FlightTrackr
//
//  Created by Unbounded on 10/6/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AirportSelectorResultsObj : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *ident;
@property NSInteger sectionNumber;

@end
