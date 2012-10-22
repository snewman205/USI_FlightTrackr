//
//  FlightStatusResults.m
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FlightStatusResults.h"

#define mainQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

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

    self.previousView = [[self.navigationController viewControllers] objectAtIndex:1];
    self.returnedFlights = [[NSArray alloc] init];
    self.filteredFlights = [[NSMutableArray alloc] init];
    self.airlineLogos = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"airtran_logo_sm.jpg"], [UIImage imageNamed:@"american_logo_sm.png"], [UIImage imageNamed:@"delta_logo_sm.png"], [UIImage imageNamed:@"easyjet_logo_sm.gif"], [UIImage imageNamed:@"expressjet_logo_sm.jpg"], [UIImage imageNamed:@"jetblue_logo_sm.png"], [UIImage imageNamed:@"southwest_airlines_logo.png"], [UIImage imageNamed:@"united_logo_sm.png"], [UIImage imageNamed:@"usairways_logo_sm.png"], nil];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:8aeb39a892fb8d7aa6129e70736bd4071a097430@flightxml.flightaware.com/json/FlightXML2/AirlineFlightSchedules?startDate=%.0f&endDate=%.0f&destination=K%@&origin=K%@&airline=%@", ([self.previousView.singletonObj.selectedDateIndex timeIntervalSince1970]-7200), ([self.previousView.singletonObj.selectedDateIndex timeIntervalSince1970]+7200), self.previousView.singletonObj.selectedDestinationIdent, self.previousView.singletonObj.selectedOriginIdent, self.previousView.singletonObj.selectedAirlineIdent2]];
    
    NSLog(@"url - %@", jsonURL);
    
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
        
        if([[[flightObj objectForKey:@"ident"] substringToIndex:3] isEqualToString:self.previousView.singletonObj.selectedAirlineIdent2])
        {
            [self.filteredFlights addObject:flightObj];
        }
    }
    
    [self.tableView reloadData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    
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
    self.previousView = [[self.navigationController viewControllers] objectAtIndex:1];
    
    // Configure the cell...
    
    double secondsSinceEpoch = [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"departuretime"] doubleValue];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"MM/dd/yy - h:mm a"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Flight #%@ (%@ to %@)", [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3], [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"origin"] substringFromIndex:1], [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"destination"] substringFromIndex:1]];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Departs %@\nOperated by %@", [dateFormat stringFromDate:[self.previousView.singletonObj epochToDate:secondsSinceEpoch]], self.previousView.singletonObj.selectedAirlineName2];
    cell.imageView.image = [self getAirlineLogo:self.previousView.singletonObj.selectedAirlineName2];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlightStatusSingleton *singletonObj2 = [FlightStatusSingleton sharedInstance];
    CheckFlightStatusSingleton *singletonObj = [CheckFlightStatusSingleton sharedInstance];
    UITableViewCell *selCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int extraLen = ([selCell.detailTextLabel.text length] == 45) ? 1 : 0;
    [dateFormatter setDateFormat:@"MM/dd/yy - h:mm a"];
    
    singletonObj.selectedDateIndex = [dateFormatter dateFromString:[selCell.detailTextLabel.text substringWithRange:NSMakeRange(8, (18 + extraLen))]];
    singletonObj.selectedFlightNo = [[[self.filteredFlights objectAtIndex:indexPath.row] valueForKey:@"ident"] substringFromIndex:3];
    singletonObj.didSearchFlight = YES;
    
    singletonObj2.didChangeFlight = YES;
    [self performSegueWithIdentifier:@"segueFlightStatusInfo" sender:self];
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

@end
