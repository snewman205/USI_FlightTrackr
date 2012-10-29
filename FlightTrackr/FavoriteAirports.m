//
//  FavoriteAirports.m
//  FlightTrackr
//
//  Created by Unbounded on 10/11/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FavoriteAirports.h"

@interface FavoriteAirports ()

@end

@implementation FavoriteAirports

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.airlineLogos = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"airtran_logo_sm.jpg"], [UIImage imageNamed:@"american_logo_sm.png"], [UIImage imageNamed:@"delta_logo_sm.png"], [UIImage imageNamed:@"easyjet_logo_sm.gif"], [UIImage imageNamed:@"expressjet_logo_sm.jpg"], [UIImage imageNamed:@"jetblue_logo_sm.png"], [UIImage imageNamed:@"southwest_airlines_logo.png"], [UIImage imageNamed:@"united_logo_sm.png"], [UIImage imageNamed:@"usairways_logo_sm.png"], nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Manage" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit)];
    
    if([singletonObj.selectedFavorites isEqualToString:@"airports"])
    {
        [self loadAirports];
    }
    else
    {
        self.btnChangeFavorites.selectedSegmentIndex = 1;
        [self loadFlights];
    }
}

#pragma mark - Table view data source

- (IBAction)doChangeFavorites:(id)sender
{
    MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
    
    if(self.btnChangeFavorites.selectedSegmentIndex == 0)
    {
        singletonObj.selectedFavorites = @"airports";
        self.loadingAirports = YES;
        [self loadAirports];
    }
    else
    {
        singletonObj.selectedFavorites = @"flights";
        self.loadingAirports = NO;
        [self loadFlights];
    }
    
}

- (void)loadAirports
{
    
    self.airports = [NSMutableArray arrayWithCapacity:1];
    self.loadingAirports = YES;
    
    if(!self.navigationItem.rightBarButtonItem)
    {
        self.editing = NO;
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Manage" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit)]];
        [self.tableView setEditing:NO animated:YES];
    }
    
    if(!self.editing)
    {
    
        LGViewHUD *hud = [LGViewHUD defaultHUD];
        hud.activityIndicatorOn = YES;
        hud.topText = @"Processing";
        hud.bottomText = @"Please wait...";
        [hud showInView:self.view];
        
    }
    
    [self.tableView setScrollEnabled:NO];
    
    NSMutableArray *airportsTemp = [NSMutableArray arrayWithCapacity:1];
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteAirports"];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *result in results)
    {
        AirportSelectorResultsObj *airport = [[AirportSelectorResultsObj alloc] init];
        airport.name = [result valueForKey:@"name"];
        airport.city = [result valueForKey:@"city"];
        airport.state = [result valueForKey:@"state"];
        airport.ident = [result valueForKey:@"identifier"];
        [airportsTemp addObject:airport];
    }
    
    for (AirportSelectorResultsObj *theAirport in airportsTemp)
    {
        
        NSInteger sect = [theCollation sectionForObject:theAirport collationStringSelector:@selector(name)];
        theAirport.sectionNumber = sect;
        
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    
    for (int i = 0; i < highSection; i++)
    {
        
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
        
    }
    
    for (AirportSelectorResultsObj *theAirport in airportsTemp)
    {
        
        [(NSMutableArray *)[sectionArrays objectAtIndex:theAirport.sectionNumber] addObject:theAirport];
        
    }
    
    for (NSMutableArray *sectionArray in sectionArrays)
    {
        
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(name)];
        [self.airports addObject:sortedSection];
        
    }
    
    if([results count] == 0)
    {
        self.editing = NO;
        [self.navigationItem setRightBarButtonItem:NULL];
        [self.tableView setEditing:NO animated:YES];
    }
    
    (!self.editing) ? [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut] : NULL;
    
    [self.tableView setScrollEnabled:YES];
    [self.tableView setRowHeight:44];
    [self.tableView reloadData];

}

- (void)loadFlights
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteFlights"];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
 
    self.loadingAirports = NO;
    self.flights = [NSMutableArray arrayWithCapacity:1];
    
    if(!self.navigationItem.rightBarButtonItem)
    {
        self.editing = NO;
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Manage" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit)]];
        [self.tableView setEditing:NO animated:YES];
    }
    
    if(!self.editing)
    {
        
        LGViewHUD *hud = [LGViewHUD defaultHUD];
        hud.activityIndicatorOn = YES;
        hud.topText = @"Processing";
        hud.bottomText = @"Please wait...";
        [hud showInView:self.view];
        
    }
    [self.tableView setScrollEnabled:NO];
    
    for(NSManagedObject *result in results)
    {
        FlightSelectorResultsObj *flight = [[FlightSelectorResultsObj alloc] init];
        flight.flightNo = [result valueForKey:@"flightNo"];
        flight.carrierIdent = [result valueForKey:@"carrierIdent"];
        flight.departs = [result valueForKey:@"departs"];
        flight.origin = [result valueForKey:@"origin"];
        flight.destination = [result valueForKey:@"destination"];
        [self.flights addObject:flight];
    }
    
    (!self.editing) ? [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut] : NULL;
    
    if([self.flights count] == 0)
    {
        self.editing = NO;
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem setRightBarButtonItem:NULL];
    }
    
    [self.tableView setScrollEnabled:YES];
    [self.tableView setRowHeight:65];
    [self.tableView reloadData];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(self.loadingAirports)
    {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }
    else
    {
        return NULL;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.airports objectAtIndex:section] count] > 0 && self.loadingAirports)
    {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(self.loadingAirports)
    {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }
    else
    {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.loadingAirports)
    {
        return [self.airports count];
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.loadingAirports)
    {
        return [[self.airports objectAtIndex:section] count];
    }
    else
    {
        return [self.flights count];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(self.loadingAirports)
    {
        
        AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
        
        if(singletonObj.selectedItem == 1)
        {
            [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        }
    
        cell.textLabel.text = airportObj.name;
        cell.imageView.image = [UIImage imageNamed:@"07-map-marker.png"];
        cell.detailTextLabel.text = [airportObj.city stringByAppendingString:[@", " stringByAppendingString:airportObj.state]];
    
        return cell;
        
    }
    else
    {
    
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        FlightSelectorResultsObj *flightObj = [self.flights objectAtIndex:indexPath.row];
        CheckFlightStatusSingleton *singletonObj = [CheckFlightStatusSingleton sharedInstance];
        double secondsSinceEpoch = [flightObj.departs doubleValue];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"MM/dd/yy - h:mm a"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Flight #%@ (%@ to %@)", flightObj.flightNo, flightObj.origin, flightObj.destination];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Departs %@\nOperated by %@", [dateFormat stringFromDate:[singletonObj epochToDate:secondsSinceEpoch]], [self getAirlineName:flightObj.carrierIdent]];
        cell.imageView.image = [self getAirlineLogo:[self getAirlineName:flightObj.carrierIdent]];
        
        return cell;
    }
    
}

- (NSString*)getAirlineName:(NSString *)airline
{
    if([airline isEqualToString:@"EGF"])
    {
        return @"American Eagle";
    }
    else if([airline isEqualToString:@"TRS"])
    {
        return @"AirTran";
    }
    else if([airline isEqualToString:@"JBU"])
    {
        return @"JetBlue";
    }
    else if([airline isEqualToString:@"EZY"])
    {
        return @"easyJet";
    }
    else if([airline isEqualToString:@"ASQ"])
    {
        return @"ExpressJet";
    }
    else if([airline isEqualToString:@"AWE"])
    {
        return @"US Airways";
    }
    else if([airline isEqualToString:@"DAL"])
    {
        return @"Delta";
    }
    else if([airline isEqualToString:@"AAL"])
    {
        return @"American Airlines";
    }
    else if([airline isEqualToString:@"UAL"])
    {
        return @"United";
    }
    else if([airline isEqualToString:@"SWA"])
    {
        return @"Southwest";
    }
    
    return NULL;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.loadingAirports)
    {
        AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteAirports"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier=%@)", airportObj.ident];
        NSError *error = nil;
    
        [request setPredicate:predicate];
        
        NSArray *results = [self.context executeFetchRequest:request error:&error];
    
        [self.context deleteObject:[results objectAtIndex:0]];
        [self.context save:&error];
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Favorite Removed" message:[NSString stringWithFormat:@"%@ has been removed from your favorite airports", airportObj.name] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [msg show];
    }
    else
    {
        FlightSelectorResultsObj *flightObj = [self.flights objectAtIndex:indexPath.row];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FavoriteFlights"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(flightNo=%@) AND (carrierIdent=%@) AND (departs=%@) AND (origin=%@) AND (destination=%@)", flightObj.flightNo, flightObj.carrierIdent, flightObj.departs, flightObj.origin, flightObj.destination];
        NSError *error = nil;
        
        [request setPredicate:predicate];
        
        NSArray *results = [self.context executeFetchRequest:request error:&error];
        
        [self.context deleteObject:[results objectAtIndex:0]];
        [self.context save:&error];
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Favorite Removed" message:[NSString stringWithFormat:@"Flight #%@ has been removed from your favorite flights", flightObj.flightNo] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [msg show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.loadingAirports)
    {
        MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
        AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
        if(singletonObj.selectedItem == 1)
        {
            AirportSingleton *airportSingleton = [AirportSingleton sharedInstance];
            airportSingleton.airportIdent = airportObj.ident;
            airportSingleton.airportName = airportObj.name;
            airportSingleton.airportCity = airportObj.city;
            airportSingleton.airportState = airportObj.state;
            airportSingleton.didChangeAirport = YES;
        
            [self performSegueWithIdentifier:@"segueAirportDetail1" sender:self];
        
        }
        else
        {
            [self performSegueWithIdentifier:@"segueCheckFlightStatus1" sender:self];
        }
    }
    else
    {
        CheckFlightStatusSingleton *singletonObj = [CheckFlightStatusSingleton sharedInstance];
        FlightStatusSingleton *singletonObj2 = [FlightStatusSingleton sharedInstance];
        FlightSelectorResultsObj *flightObj = [self.flights objectAtIndex:indexPath.row];
        UITableViewCell *selCell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSScanner *scanner = [NSScanner scannerWithString:selCell.detailTextLabel.text];
        NSString *stringPortion = [[NSString alloc] init];
        [scanner scanUpToString:@"\n" intoString:&stringPortion];
        int extraLen = ([stringPortion length] == 26) ? 0 : 1;
        [dateFormatter setDateFormat:@"MM/dd/yy - h:mm a"];
        
        singletonObj2.didChangeFlight = YES;
        singletonObj.selectedDateIndex1 = [dateFormatter dateFromString:[selCell.detailTextLabel.text substringWithRange:NSMakeRange(8, (18 + extraLen))]];
        singletonObj.selectedAirlineIdent1 = flightObj.carrierIdent;
        singletonObj.selectedFlightNo = flightObj.flightNo;
        NSLog(@"got to segue");
        [self performSegueWithIdentifier:@"segueFromFavAirports" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepping segue");
    if(self.loadingAirports)
    {
        CheckFlightStatus *previousView = [[self.navigationController viewControllers] objectAtIndex:1];
        NSIndexPath *selCellPath = self.tableView.indexPathForSelectedRow;
        AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:selCellPath.section] objectAtIndex:selCellPath.row];
    
        if([segue.identifier isEqualToString:@"segueCheckFlightStatus1"])
        {
            NSLog(@"doing stuff");
            if([previousView.singletonObj.destOrOriginSelected isEqualToString:@"Origin"])
            {
                previousView.singletonObj.selectedOriginIdent = airportObj.ident;
                previousView.singletonObj.selectedOriginAirport = airportObj.name;
            }
            else
            {
                previousView.singletonObj.selectedDestinationIdent = airportObj.ident;
                previousView.singletonObj.selectedDestinationAirport = airportObj.name;
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.loadingAirports)
    {
        [self loadAirports];
    }
    else
    {
        [self loadFlights];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doEdit
{
    if(self.tableView.editing)
    {
        self.editing = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"Manage"];
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        self.editing = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)viewDidUnload {
    [self setBtnChangeFavorites:nil];
    [super viewDidUnload];
}
@end
