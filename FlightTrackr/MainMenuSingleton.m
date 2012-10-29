//
//  MainMenuSingleton.m
//  FlightTrackr
//
//  Created by Unbounded on 10/8/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "MainMenuSingleton.h"

@implementation MainMenuSingleton

static MainMenuSingleton *sharedSingletonClass = nil;

+ (MainMenuSingleton *)sharedInstance
{
    if(sharedSingletonClass == nil)
    {
        sharedSingletonClass = [[MainMenuSingleton alloc] init];
    }
    
    return sharedSingletonClass;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.selectedItem = -1;
        self.selectedFavorites = [[NSString alloc] init];
    }
    
    return self;
}

@end
