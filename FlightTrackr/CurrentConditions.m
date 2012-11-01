//
//  CurrentConditions.m
//  FlightTrackr
//
//  Created by Unbounded on 10/22/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "CurrentConditions.h"

@interface CurrentConditions ()

@end

@implementation CurrentConditions

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.singletonObj = [FlightStatusSingleton sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.navigationItem setTitle:@"Local Conditions"];
    self.sectionHeaders = [NSArray arrayWithObjects:self.singletonObj.originLocation, self.singletonObj.destinationLocation, nil];
    self.dataReturned = NO;
    self.originForecast = [[ForecastObject alloc] init];
    self.destinationForecast = [[ForecastObject alloc] init];
    self.userUnits = [[NSUserDefaults standardUserDefaults] valueForKey:@"temp_units"];
    self.displayWindConditions = [[NSUserDefaults standardUserDefaults] boolForKey:@"wind_conditions"];
    [self fetchForecast];
}

- (void)fetchForecast
{    
    NSRange originCommaLocation = [self.singletonObj.originLocation rangeOfString:@","];
    NSString *originState = [self.singletonObj.originLocation substringFromIndex:([self.singletonObj.originLocation length] - 2)];
    NSString *originCity = (originCommaLocation.location != NSNotFound) ? [[self.singletonObj.originLocation substringToIndex:originCommaLocation.location] stringByReplacingOccurrencesOfString:@" " withString:@"_"] : nil;
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@/%@.json", WUNDERGROUND_KEY, originState, originCity]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Processing";
    hud.bottomText = @"Please wait...";
    [hud showInView:self.view];
    
    dispatch_async(mainQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       
                       [self performSelectorOnMainThread:@selector(dataRetreived:) withObject:data waitUntilDone:YES];
                   });
}

- (void)dataRetreived:(NSData*)response
{
    
    NSError *error;
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSDictionary *jsonDict = [rootDict objectForKey:@"current_observation"];
    
    self.originForecast.iconURL = [jsonDict valueForKey:@"icon_url"];
    self.originForecast.currentConditions = [jsonDict valueForKey:@"weather"];
    self.originForecast.currentTemperature = [[jsonDict valueForKey:[NSString stringWithFormat:@"temp_%@", self.userUnits]] doubleValue];
    self.originForecast.feelsLikeTemperature = [[jsonDict valueForKey:[NSString stringWithFormat:@"feelslike_%@", self.userUnits]] doubleValue];
    
    if(self.displayWindConditions)
    {
        self.originForecast.windStr = [jsonDict valueForKey:@"wind_string"];
    }
    
    NSRange destinationCommaLocation = [self.singletonObj.destinationLocation rangeOfString:@","];
    NSString *destinationState = [self.singletonObj.destinationLocation substringFromIndex:([self.singletonObj.destinationLocation length] - 2)];
    NSString *destinationCity = (destinationCommaLocation.location != NSNotFound) ? [[self.singletonObj.destinationLocation substringToIndex:destinationCommaLocation.location] stringByReplacingOccurrencesOfString:@" " withString:@"_"] : nil;
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@/%@.json", WUNDERGROUND_KEY, destinationState, destinationCity]];
    
    dispatch_async(mainQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       
                       [self performSelectorOnMainThread:@selector(dataRetreived2:) withObject:data waitUntilDone:YES];
                   });
    
}

- (void)dataRetreived2:(NSData*)response
{
    NSError *error;
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSDictionary *jsonDict = [rootDict objectForKey:@"current_observation"];
    
    self.destinationForecast.iconURL = [jsonDict valueForKey:@"icon_url"];
    self.destinationForecast.currentConditions = [jsonDict valueForKey:@"weather"];
    self.destinationForecast.currentTemperature = [[jsonDict valueForKey:[NSString stringWithFormat:@"temp_%@", self.userUnits]] doubleValue];
    self.destinationForecast.feelsLikeTemperature = [[jsonDict valueForKey:[NSString stringWithFormat:@"feelslike_%@", self.userUnits]] doubleValue];
    
    if(self.displayWindConditions)
    {
        self.destinationForecast.windStr = [jsonDict valueForKey:@"wind_string"];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    
    self.dataReturned = YES;
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(self.dataReturned)
    {
        return [self.sectionHeaders count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Assign section headers
    return [self.sectionHeaders objectAtIndex:(NSUInteger)section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(self.dataReturned)
    {
        switch(section)
        {
            case 0:
                return (self.displayWindConditions) ? 3 : 2;
                break;
                
            case 1:
                return (self.displayWindConditions) ? 3 : 2;
                break;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    switch(indexPath.section)
    {
        case 0:
            
            if(indexPath.row == 0)
            {
                NSURL *iconURL = [[NSURL alloc] initWithString:self.originForecast.iconURL];
                NSData *iconData = [NSData dataWithContentsOfURL:iconURL];
                
                cell.imageView.image = [UIImage imageWithData:iconData];
                cell.textLabel.text = @"Currently:";
                cell.detailTextLabel.text = self.originForecast.currentConditions;
            }
            else if(indexPath.row == 1)
            {
                cell.imageView.image = [UIImage imageNamed:@"thermometer_icon.png"];
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = @"Actual Temp:\nFeels Like:";
                cell.detailTextLabel.numberOfLines = 2;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f °%@\n%.1f °%@", self.originForecast.currentTemperature, [self.userUnits uppercaseString], self.originForecast.feelsLikeTemperature, [self.userUnits uppercaseString]];
            }
            else if(indexPath.row == 2)
            {
                cell.imageView.image = [UIImage imageNamed:@"wind_icon.png"];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.text = @"Wind:";
                cell.detailTextLabel.numberOfLines = 2;
                cell.detailTextLabel.text = self.originForecast.windStr;
            }
            
        break;
            
        case 1:
            
            if(indexPath.row == 0)
            {
                NSURL *iconURL = [[NSURL alloc] initWithString:self.destinationForecast.iconURL];
                NSData *iconData = [NSData dataWithContentsOfURL:iconURL];
                
                cell.imageView.image = [UIImage imageWithData:iconData];
                cell.textLabel.text = @"Currently:";
                cell.detailTextLabel.text = self.destinationForecast.currentConditions;
            }
            else if(indexPath.row == 1)
            {
                cell.imageView.image = [UIImage imageNamed:@"thermometer_icon.png"];
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = @"Actual Temp:\nFeels Like:";
                cell.detailTextLabel.numberOfLines = 2;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f °%@\n%.1f °%@", self.destinationForecast.currentTemperature, [self.userUnits uppercaseString], self.destinationForecast.feelsLikeTemperature, [self.userUnits uppercaseString]];
            }
            else if(indexPath.row == 2)
            {
                cell.imageView.image = [UIImage imageNamed:@"wind_icon.png"];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.text = @"Wind:";
                cell.detailTextLabel.numberOfLines = 2;
                cell.detailTextLabel.text = self.destinationForecast.windStr;
            }
            
        break;
    }
    
    return cell;
}

@end
