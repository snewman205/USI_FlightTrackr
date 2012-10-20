//
//  MainMenuSingleton.h
//  FlightTrackr
//
//  Created by Unbounded on 10/8/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainMenuSingleton : NSObject

@property (nonatomic) NSInteger selectedItem;

+ (MainMenuSingleton *)sharedInstance;

@end
