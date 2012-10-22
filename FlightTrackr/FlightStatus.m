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

    self.sectionHeaders = [NSArray arrayWithObjects:@"Status", @"", @"", @"", nil];
    self.previousView = [[self.navigationController viewControllers] objectAtIndex:1];
    self.filteredFlights = [[NSMutableArray alloc] init];
    self.aircraftMfg = [[NSString alloc] init];
    self.aircraftType = [[NSString alloc] init];
    self.dataReturned = NO;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.aircraftMfg = @"";
    self.aircraftType = @"";
}

- (void)loadTableData
{
    // get params from previous selections & force zero seconds for selected date & time
    
    NSString *selectedIdent;
    NSString *sectionForParams;
    
    if([self.previousView.singletonObj.selectedAirlineIdent1 isEqualToString:@""])
    {
        sectionForParams = @"1";
        selectedIdent = self.previousView.singletonObj.selectedAirlineIdent2;
    }
    else
    {
        sectionForParams = @"";
        selectedIdent = self.previousView.singletonObj.selectedAirlineIdent1;
    }
    
    NSDate *selectedDate = ([sectionForParams isEqualToString:@""]) ? self.previousView.singletonObj.selectedDateIndex1 : self.previousView.singletonObj.selectedDateIndex;
    NSTimeInterval time = floor([selectedDate timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    self.roundedDate = [NSDate dateWithTimeIntervalSinceReferenceDate: time];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/FlightInfoEx?ident=%@%@", selectedIdent, self.previousView.singletonObj.selectedFlightNo]];
    
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
    [self loadTableData];
}

- (void)dataRetreived2:(NSData*)dataResponse
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&error];
    NSDictionary *allData = [jsonDict objectForKey:@"AircraftTypeResult"];
    self.aircraftMfg = [allData objectForKey:@"manufacturer"];
    self.aircraftType = [allData objectForKey:@"type"];
    self.dataReturned = YES;
    
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
    
    if([self.aircraftMfg isEqualToString:@""] && [self.aircraftType isEqualToString:@""])
    {
    
        NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/AircraftType?type=%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"aircrafttype"]]];
                                                                                                                                                                                                
        dispatch_async(mainQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       
                       [self performSelectorOnMainThread:@selector(dataRetreived2:) withObject:data waitUntilDone:YES];
                   });
        
        self.dataReturned = NO;
        
    }
    else
    {
        self.dataReturned = YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [self.tableView reloadData];
    }
    
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
                return 1;
            break;
        
            case 1:
                return 2;
            break;
                
            case 2:
                return 3;
            break;
            
            case 3:
                return 3;
            break;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    
    singletonObj.faFlightID = [[self.filteredFlights objectAtIndex:0] valueForKey:@"faFlightID"];
    singletonObj.flightIdent = [[self.filteredFlights objectAtIndex:0] valueForKey:@"ident"];
    
    if(indexPath.section == 0)
    {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        if(([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] > 0) && ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] == 0))
        {
            cell.textLabel.text = @"En Route";
            //[[self.tabBarController.tabBar.subviews objectAtIndex:2] setEnabled:YES];
        }
        else if(([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] > 0) && ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] > 0))
        {
            cell.textLabel.text = @"Arrived";
            //[[self.tabBarController.tabBar.subviews objectAtIndex:2] setEnabled:NO];
        }
        else if([[NSDate date] timeIntervalSince1970] > [[[self.filteredFlights objectAtIndex:0] valueForKey:@"filed_departuretime"] doubleValue])
        {
            cell.textLabel.text = @"Delayed";
            //[[self.tabBarController.tabBar.subviews objectAtIndex:2] setEnabled:YES];
        }
        else if([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] == 0)
        {
            cell.textLabel.text = @"Scheduled";
            //[[self.tabBarController.tabBar.subviews objectAtIndex:2] setEnabled:NO];
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
            singletonObj.originAirport = [[self.filteredFlights objectAtIndex:0] valueForKey:@"originName"];
            singletonObj.originLocation = [[self.filteredFlights objectAtIndex:0] valueForKey:@"originCity"];
            cell1.textLabel.text = @"Origin:";
            cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"originName"], [[self.filteredFlights objectAtIndex:0] valueForKey:@"originCity"]];
        }
        
        else if(indexPath.row == 1)
        {
        
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"filed_departuretime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
                    
            cell1.textLabel.text = @"Est. Departure:";
            cell1.detailTextLabel.text = [dateFormat stringFromDate:[self.previousView.singletonObj epochToDate:secondsSinceEpoch]];
                        
        }
    
        else if(indexPath.row == 2)
        {
            
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
                
            cell1.textLabel.text = @"Actual Departure:";
            cell1.detailTextLabel.text = ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualdeparturetime"] doubleValue] > 0) ? [dateFormat stringFromDate:[self.previousView.singletonObj epochToDate:secondsSinceEpoch]] : @"Unavailable";
                
        }
            
        return cell1;
            
    }
    
    else if(indexPath.section == 3)
    {
        
        static NSString *CellIdentifier1 = @"Cell1";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if(indexPath.row == 0)
        {
            singletonObj.destinationAirport = [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationName"];
            singletonObj.destinationLocation = [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationCity"];
            cell1.textLabel.text = @"Destination:";
            cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationName"], [[self.filteredFlights objectAtIndex:0] valueForKey:@"destinationCity"]];
        }
        
        else if(indexPath.row == 1)
        {
            
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"estimatedarrivaltime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
            
            cell1.textLabel.text = @"Est. Arrival:";
            cell1.detailTextLabel.text = [dateFormat stringFromDate:[self.previousView.singletonObj epochToDate:secondsSinceEpoch]];
            
        }
        
        else if(indexPath.row == 2)
        {
            
            double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] + 3600;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMM dd, yyyy\nh:mm a"];
            
            cell1.textLabel.text = @"Actual Arrival:";
            cell1.detailTextLabel.text = ([[[self.filteredFlights objectAtIndex:0] valueForKey:@"actualarrivaltime"] doubleValue] > 0) ? [dateFormat stringFromDate:[self.previousView.singletonObj epochToDate:secondsSinceEpoch]] : @"Unavailable";
            
        }
        
        return cell1;
        
    }
    
    return NULL;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
