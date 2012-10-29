//
//  FlightStatus.m
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FlightStatus.h"

#define mainQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FlightStatus ()

@end

@implementation FlightStatus

@synthesize aircraftMfg, aircraftType;

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
    
    NSLog(@"loading view");
    
    self.sectionHeaders = [NSArray arrayWithObjects:@"Status", @"", @"", @"", nil];
    self.filteredFlights = [[NSMutableArray alloc] init];
    self.aircraftMfg = [[NSString alloc] init];
    self.aircraftType = [[NSString alloc] init];
    self.origTerm = [[NSString alloc] init];
    self.origGate = [[NSString alloc] init];
    self.destTerm = [[NSString alloc] init];
    self.destGate = [[NSString alloc] init];
    self.dataReturned = NO;
    self.singletonObj = [FlightStatusSingleton sharedInstance];
    self.singletonObj1 = [CheckFlightStatusSingleton sharedInstance];
}

- (void)loadTableData
{
    // get params from previous selections & force zero seconds for selected date & time
    
    NSString *selectedIdent;
    NSString *sectionForParams;
    
    if([self.singletonObj1.selectedAirlineIdent1 isEqualToString:@""])
    {
        sectionForParams = @"1";
        selectedIdent = self.singletonObj1.selectedAirlineIdent2;
    }
    else
    {
        sectionForParams = @"";
        selectedIdent = self.singletonObj1.selectedAirlineIdent1;
    }
    
    NSDate *selectedDate = ([sectionForParams isEqualToString:@""]) ? self.singletonObj1.selectedDateIndex1 : self.singletonObj1.selectedDateIndex;
    
    NSTimeInterval time = floor([selectedDate timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    self.roundedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    self.singletonObj.carrierIdent = selectedIdent;
    self.singletonObj.flightNo = self.singletonObj1.selectedFlightNo;
    
    
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/FlightInfoEx?ident=%@%@", selectedIdent, self.singletonObj1.selectedFlightNo]];
    
    for(UITabBarItem *item in [[self.tabBarController tabBar] items])
        [item setEnabled:NO];
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    self.dataReturned = NO;
    [self.filteredFlights removeAllObjects];
    self.aircraftMfg = @"";
    self.aircraftType = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"loading table data");
    self.actSheet = [UIActionSheet alloc];
    [self.tabBarController.navigationItem setTitle:@"Flight Status"];
    [self loadTableData];
}

- (void)dataRetreived2:(NSData*)dataResponse
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&error];
    NSDictionary *allData = [jsonDict objectForKey:@"AircraftTypeResult"];
    
    self.aircraftMfg = [allData objectForKey:@"manufacturer"];
    self.aircraftType = [allData objectForKey:@"type"];
        
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/AirlineFlightInfo?faFlightID=%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"faFlightID"]]];
    
    dispatch_async(mainQueue, ^
                    {
                        NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                           
                        [self performSelectorOnMainThread:@selector(dataRetreived3:) withObject:data waitUntilDone:YES];
                    });
        
    self.dataReturned = NO;
}

- (void)dataRetreived3:(NSData*)dataResponse
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&error];
    NSDictionary *allData = [jsonDict objectForKey:@"AirlineFlightInfoResult"];
    
    self.origTerm = [allData objectForKey:@"terminal_orig"];
    self.origGate = [allData objectForKey:@"gate_orig"];
    self.destTerm = [allData objectForKey:@"terminal_dest"];
    self.destGate = [allData objectForKey:@"gate_dest"];
    
    self.singletonObj.faFlightID = [[self.filteredFlights objectAtIndex:0] valueForKey:@"faFlightID"];
    self.singletonObj.flightIdent = [[self.filteredFlights objectAtIndex:0] valueForKey:@"ident"];
    self.singletonObj.originAirport = [[self.filteredFlights objectAtIndex:0] valueForKey:@"originName"];
    self.singletonObj.originLocation = [[self.filteredFlights objectAtIndex:0] valueForKey:@"originCity"];
    self.singletonObj.destinationAirport = [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationName"];
    self.singletonObj.destinationLocation = [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationCity"];
    self.singletonObj.originIdent = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"origin"] substringFromIndex:1];
    self.singletonObj.destinationIdent = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"destination"] substringFromIndex:1];
    self.singletonObj.departs = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"filed_departuretime"] doubleValue] + 3600;
    self.singletonObj.bagClaim = [allData objectForKey:@"bag_claim"];
    self.dataReturned = YES;
    
    for(UITabBarItem *item in [[self.tabBarController tabBar] items])
        [item setEnabled:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    [self.tableView reloadData];
}

- (void)dataRetreived:(NSData*)dataResponse
{
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&error];
    
    NSDictionary *allData = [jsonDict objectForKey:@"FlightInfoExResult"];
    
    NSArray *returnedFlights = [allData objectForKey:@"flights"];
    
    for(int i = 0; i < [returnedFlights count]; i++)
    {
        NSDictionary *flightObj = [returnedFlights objectAtIndex:i];
        
        if([[NSString stringWithFormat:@"%@", [flightObj objectForKey:@"filed_departuretime"]] isEqualToString:[NSString stringWithFormat:@"%.0f", [self.roundedDate timeIntervalSince1970]]])
        {
            [self.filteredFlights addObject:flightObj];
        }
    }
    
    if([self.filteredFlights count] == 0)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[LGViewHUD defaultHUD] setActivityIndicatorOn:NO];
        [[LGViewHUD defaultHUD] setTopText:@"No results found"];
        [[LGViewHUD defaultHUD] setBottomText:@"Please try again"];
        return;
    }
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/AircraftType?type=%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"aircrafttype"]]];
                                                                                                                                                                                                
    dispatch_async(mainQueue, ^
                {
                    NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       
                    [self performSelectorOnMainThread:@selector(dataRetreived2:) withObject:data waitUntilDone:YES];
                });
        
    self.dataReturned = NO;
        
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
        int numRows = 3;
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:@"show_terminal"])
        {
            numRows = 4;
        }
        if([[NSUserDefaults standardUserDefaults] valueForKey:@"show_gate"])
        {
            numRows = 5;
        }
        
        switch(section)
        {
            case 0:
                return 1;
            break;
        
            case 1:
                return 2;
            break;
                
            case 2:
                return numRows;
            break;
            
            case 3:
                return numRows;
            break;
        }
    }
    
    return 0;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0)
    {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        [[self.tabBarController.tabBar.items objectAtIndex:3] setEnabled:([self.singletonObj.bagClaim isEqualToString:@""]) ? NO : YES];
        
        if(([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] > 0) && ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] == 0))
        {
            [cell.textLabel setTextColor:[UIColor blueColor]];
            cell.textLabel.text = @"En Route";
            [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:YES];
        }
        else if(([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] > 0) && ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] > 0))
        {
            [cell.textLabel setTextColor:[self colorFromHexString:@"#347235"]];
            cell.textLabel.text = @"Arrived";
            [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:NO];
        }
        else if([[NSDate date] timeIntervalSince1970] > [[[self.filteredFlights objectAtIndex:0] valueForKey:@"filed_departuretime"] doubleValue])
        {
            [cell.textLabel setTextColor:[UIColor redColor]];
            cell.textLabel.text = @"Delayed";
            [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:NO];
        }
        else if([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] == 0)
        {
            [cell.textLabel setTextColor:[UIColor blackColor]];
            cell.textLabel.text = @"Scheduled";
            [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:NO];
        }
            
        return cell;
    }
    
    else if(indexPath.section == 1)
    {
        
        static NSString *CellIdentifier1 = @"Cell1";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if(indexPath.row == 0)
        {
        
            cell1.textLabel.text = @"Est. Duration:";
            cell1.detailTextLabel.text = [[self.filteredFlights objectAtIndex:0] valueForKey:@"filed_ete"];
            
        }
        else
        {
            cell1.textLabel.text = @"Aircraft Type:";
            cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.aircraftMfg, self.aircraftType];
        }
        
        return cell1;
        
    }
    
    else if(indexPath.section == 2)
    {
    
        static NSString *CellIdentifier1 = @"Cell1";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if(indexPath.row == 0)
        {
            cell1.textLabel.text = @"Origin:";
            cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"originName"], [[self.filteredFlights objectAtIndex:0] valueForKey:@"originCity"]];
        }
        
        else if(indexPath.row == 1)
        {
            cell1.textLabel.text = @"Terminal:";
            cell1.detailTextLabel.text = (![self.origTerm isEqualToString:@""]) ? self.origTerm : @"Unavailable";
        }
        
        else if(indexPath.row == 2)
        {
            cell1.textLabel.text = @"Gate:";
            cell1.detailTextLabel.text = (![self.origGate isEqualToString:@""]) ? self.origGate : @"Unavailable";
        }
        
        else if(indexPath.row == 3)
        {
        
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"filed_departuretime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
                    
            cell1.textLabel.text = @"Est. Departure:";
            cell1.detailTextLabel.text = [dateFormat stringFromDate:[self.singletonObj1 epochToDate:secondsSinceEpoch]];
                        
        }
    
        else if(indexPath.row == 4)
        {
            
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
                
            cell1.textLabel.text = @"Actual Departure:";
            cell1.detailTextLabel.text = ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] > 0) ? [dateFormat stringFromDate:[self.singletonObj1 epochToDate:secondsSinceEpoch]] : @"Unavailable";
                
        }
            
        return cell1;
            
    }
    
    else if(indexPath.section == 3)
    {
        
        static NSString *CellIdentifier1 = @"Cell1";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if(indexPath.row == 0)
        {
            cell1.textLabel.text = @"Destination:";
            cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationName"], [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationCity"]];
        }
        
        else if(indexPath.row == 1)
        {
            cell1.textLabel.text = @"Terminal:";
            cell1.detailTextLabel.text = (![self.destTerm isEqualToString:@""]) ? self.destTerm : @"Unavailable";
        }
        
        else if(indexPath.row == 2)
        {
            cell1.textLabel.text = @"Gate:";
            cell1.detailTextLabel.text = (![self.destGate isEqualToString:@""]) ? self.destGate : @"Unavailable";
        }
        
        else if(indexPath.row == 3)
        {
            
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"estimatedarrivaltime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
            
            cell1.textLabel.text = @"Est. Arrival:";
            cell1.detailTextLabel.text = [dateFormat stringFromDate:[self.singletonObj1 epochToDate:secondsSinceEpoch]];
            
        }
        
        else if(indexPath.row == 4)
        {
            
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
            
            cell1.textLabel.text = @"Actual Arrival:";
            cell1.detailTextLabel.text = ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] > 0) ? [dateFormat stringFromDate:[self.singletonObj1 epochToDate:secondsSinceEpoch]] : @"Unavailable";
            
        }
        
        return cell1;
        
    }
    
    return NULL;

}

@end
