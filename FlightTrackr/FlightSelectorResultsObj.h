//
//  FlightSelectorResultsObj.h
//  FlightTrackr
//
//  Created by Unbounded on 10/24/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightSelectorResultsObj : NSObject

@property (strong, nonatomic) NSString *flightNo;
@property (strong, nonatomic) NSString *carrierIdent;
@property (strong, nonatomic) NSNumber *departs;
@property (strong, nonatomic) NSString *origin;
@property (strong, nonatomic) NSString *destination;

@end
