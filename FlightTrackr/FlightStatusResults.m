//
//  FlightStatusResults.m
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FlightStatusResults.h"

@interface FlightStatusResults ()

@end

@implementation FlightStatusResults

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

    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    self.singletonObj = [CheckFlightStatusSingleton sharedInstance];
    self.returnedFlights = [[NSArray alloc] init];
    self.filteredFlights = [[NSMutableArray alloc] init];
    self.airlineLogos = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"airtran_logo_sm.jpg"], [UIImage imageNamed:@"american_logo_sm.png"], [UIImage imageNamed:@"delta_logo_sm.png"], [UIImage imageNamed:@"easyjet_logo_sm.gif"], [UIImage imageNamed:@"expressjet_logo_sm.jpg"], [UIImage imageNamed:@"jetblue_logo_sm.png"], [UIImage imageNamed:@"southwest_airlines_logo.png"], [UIImage imageNamed:@"united_logo_sm.png"], [UIImage imageNamed:@"usairways_logo_sm.png"], nil];
    [self.tableView setScrollEnabled:NO];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@flightxml.flightaware.com/json/FlightXML2/AirlineFlightSchedules?startDate=%.0f&endDate=%.0f&destination=K%@&origin=K%@&airline=%@", FLIGHT_AWARE_USERNAME, FLIGHT_AWARE_KEY, ([self.singletonObj.selectedDateIndex timeIntervalSince1970]-7200), ([self.singletonObj.selectedDateIndex timeIntervalSince1970]+7200), self.singletonObj.selectedDestinationIdent, self.singletonObj.selectedOriginIdent, self.singletonObj.selectedAirlineIdent2]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Searching";
    hud.bottomText = @"Please wait...";
    [hud showInView:self.view];
    
    dispatch_async(mainQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       
                       [self performSelectorOnMainThread:@selector(dataRetreived:) withObject:data waitUntilDone:YES];
                   });
    
}

- (void)dataRetreived:(NSData*)dataResponse
{
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&error];
    
    NSDictionary *allData = [jsonDict objectForKey:@"AirlineFlightSchedulesResult"];
    
    self.returnedFlights = [allData objectForKey:@"data"];
    
    for(int i = 0; i < [self.returnedFlights count]; i++)
    {
        NSDictionary *flightObj = [self.returnedFlights objectAtIndex:i];
        
        if([[[flightObj objectForKey:@"ident"] substringToIndex:3] isEqualToString:self.singletonObj.selectedAirlineIdent2])
        {
            [self.filteredFlights addObject:flightObj];
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if([self.filteredFlights count] == 0)
    {
        [[LGViewHUD defaultHUD] setActivityIndicatorOn:NO];
        [[LGViewHUD defaultHUD] setTopText:@"No results found"];
        [[LGViewHUD defaultHUD] setBottomText:@"Please try again"];
    }
    else
    {
        [self.tableView setScrollEnabled:YES];
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        
        NSManagedObject *newFavFlight = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteFlights" inManagedObjectContext:self.context];
        NSNumber *departureTime = [NSNumber numberWithDouble:[[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"departuretime"] doubleValue]];
        
        [newFavFlight setValue:[[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3] forKey:@"flightNo"];
        [newFavFlight setValue:self.singletonObj.selectedAirlineIdent2 forKey:@"carrierIdent"];
        [newFavFlight setValue:departureTime forKey:@"departs"];
        [newFavFlight setValue:[[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"origin"] substringFromIndex:1] forKey:@"origin"];
        [newFavFlight setValue:[[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"destination"] substringFromIndex:1] forKey:@"destination"];
        
        NSError *error;
        
        if(![self.context save:&error])
        {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to save favorite" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [error show];
            return;
        }
        else
        {
            UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Favorite Added" message:[NSString stringWithFormat:@"Flight #%@ has been added to your favorite flights", [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3]] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [msg show];
        }
        
    }
    else if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSNumber *departureTime = [NSNumber numberWithDouble:[[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"departuretime"] doubleValue]];
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteFlights"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(flightNo=%@) AND (carrierIdent=%@) AND (departs=%@) AND (origin=%@) AND (destination=%@)", [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3],self.singletonObj.selectedAirlineIdent2, departureTime, [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"origin"] substringFromIndex:1], [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"destination"] substringFromIndex:1]];
        NSError *error = nil;
        
        [request setPredicate:predicate];
        
        NSArray *results = [self.context executeFetchRequest:request error:&error];
        
        [self.context deleteObject:[results objectAtIndex:0]];
        [self.context save:&error];
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Favorite Removed" message:[NSString stringWithFormat:@"Flight #%@ has been removed from your favorite flights", [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3]] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [msg show];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *departureTime = [NSNumber numberWithDouble:[[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"departuretime"] doubleValue]];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteFlights"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(flightNo=%@) AND (carrierIdent=%@) AND (departs=%@) AND (origin=%@) AND (destination=%@)", [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3],self.singletonObj.selectedAirlineIdent2, departureTime, [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"origin"] substringFromIndex:1], [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"destination"] substringFromIndex:1]];
    NSError *error = nil;
    
    [request setPredicate:predicate];
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    if([results count] > 0)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleInsert;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.filteredFlights count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"departuretime"] doubleValue];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"MM/dd/yy - h:mm a"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Flight #%@ (%@ to %@)", [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3], [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"origin"] substringFromIndex:1], [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"destination"] substringFromIndex:1]];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Departs %@\nOperated by %@", [dateFormat stringFromDate:[self.singletonObj epochToDate:secondsSinceEpoch]], self.singletonObj.selectedAirlineName2];
    cell.imageView.image = [self getAirlineLogo:self.singletonObj.selectedAirlineName2];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FlightStatusSingleton *singletonObj2 = [FlightStatusSingleton sharedInstance];
    UITableViewCell *selCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSScanner *scanner = [NSScanner scannerWithString:selCell.detailTextLabel.text];
    NSString *stringPortion = [[NSString alloc] init];
    [scanner scanUpToString:@"\n" intoString:&stringPortion];
    int extraLen = ([stringPortion length] == 26) ? 0 : 1;
    [dateFormatter setDateFormat:@"MM/dd/yy - h:mm a"];
    
    self.singletonObj.selectedDateIndex = [dateFormatter dateFromString:[selCell.detailTextLabel.text substringWithRange:NSMakeRange(8, (18 + extraLen))]];
    
    self.singletonObj.selectedFlightNo = [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3];
    self.singletonObj.didSearchFlight = YES;
    
    singletonObj2.didChangeFlight = YES;
    [self performSegueWithIdentifier:@"segueFlightStatusInfo" sender:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView reloadData];
}

- (IBAction)btnEdit:(id)sender
{
    if(self.tableView.editing)
    {
        self.btnDoEdit.title = @"Favorites";
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        self.btnDoEdit.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}

- (UIImage*)getAirlineLogo:(NSString *)airline
{
    if([airline isEqualToString:@"AirTran"])
    {
        return [self.airlineLogos objectAtIndex:0];
    }
    else if([airline isEqualToString:@"American Airlines"])
    {
        return [self.airlineLogos objectAtIndex:1];
    }
    else if([airline isEqualToString:@"Amerian Eagle"])
    {
        return [self.airlineLogos objectAtIndex:1];
    }
    else if([airline isEqualToString:@"Delta"])
    {
        return [self.airlineLogos objectAtIndex:2];
    }
    else if([airline isEqualToString:@"easyJet"])
    {
        return [self.airlineLogos objectAtIndex:3];
    }
    else if([airline isEqualToString:@"ExpressJet"])
    {
        return [self.airlineLogos objectAtIndex:4];
    }
    else if([airline isEqualToString:@"JetBlue"])
    {
        return [self.airlineLogos objectAtIndex:5];
    }
    else if([airline isEqualToString:@"Southwest"])
    {
        return [self.airlineLogos objectAtIndex:6];
    }
    else if([airline isEqualToString:@"United"])
    {
        return [self.airlineLogos objectAtIndex:7];
    }
    else if([airline isEqualToString:@"US Airways"])
    {
        return [self.airlineLogos objectAtIndex:8];
    }
    
    return NULL;
}

- (void)viewDidUnload {
    [self setBtnDoEdit:nil];
    [super viewDidUnload];
}
@end
