//
//  BaggageClaim.m
//  FlightTrackr
//
//  Created by Unbounded on 10/22/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "BaggageClaim.h"

@interface BaggageClaim ()

@end

@implementation BaggageClaim

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.navigationItem setTitle:@"Baggage Claim"];
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    self.lblBaggageClaim.text = ([singletonObj.bagClaim isEqualToString:@""]) ? @"Unavailable" : singletonObj.bagClaim;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLblBaggageClaim:nil];
    [super viewDidUnload];
}
@end
