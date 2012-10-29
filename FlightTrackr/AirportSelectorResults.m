//
//  AirportSelectorResults.m
//  FlightTrackr
//
//  Created by Unbounded on 9/30/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportSelectorResults.h"

@interface AirportSelectorResults ()

@end

@implementation AirportSelectorResults

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

    [self loadTableData];

}

- (void)loadTableData
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Searching";
    hud.bottomText = @"Please wait...";
    [hud showInView:self.view];
    
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSArray *tempArray = [[NSArray alloc] init];
    NSMutableArray *airportsTemp = [[NSMutableArray alloc] initWithCapacity:1];
    
    self.airports = [NSMutableArray arrayWithCapacity:1];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Airports" ofType:@"plist"];
    
    if (thePath)
    {
        
        NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
        
        tempArray = [rootDict objectForKey:@"Airports"];
        
        airportsTemp = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *airportDict in tempArray)
        {
            if(self.inpIdent.length > 0)
            {
                if([[airportDict valueForKey:@"Identifier"] isEqualToString:self.inpIdent])
                {
                    
                    AirportSelectorResultsObj *airport = [[AirportSelectorResultsObj alloc] init];
                    airport.name = [airportDict valueForKey:@"Name"];
                    airport.city = [airportDict valueForKey:@"City"];
                    airport.state = [airportDict valueForKey:@"State"];
                    airport.ident = [airportDict valueForKey:@"Identifier"];
                    [airportsTemp addObject:airport];
                    
                }
            }
            else
            {
                
                if(self.inpCity.length > 0)
                {
                    
                    if([[airportDict valueForKey:@"State"] isEqualToString:self.inpState] && [[airportDict valueForKey:@"City"] isEqualToString:self.inpCity])
                    {
                        
                        AirportSelectorResultsObj *airport = [[AirportSelectorResultsObj alloc] init];
                        airport.name = [airportDict valueForKey:@"Name"];
                        airport.city = [airportDict valueForKey:@"City"];
                        airport.state = [airportDict valueForKey:@"State"];
                        airport.ident = [airportDict valueForKey:@"Identifier"];
                        [airportsTemp addObject:airport];
                        
                    }
                    
                }
                else
                {
                    
                    if([[airportDict valueForKey:@"State"] isEqualToString:self.inpState])
                    {
                        
                        AirportSelectorResultsObj *airport = [[AirportSelectorResultsObj alloc] init];
                        airport.name = [airportDict valueForKey:@"Name"];
                        airport.city = [airportDict valueForKey:@"City"];
                        airport.state = [airportDict valueForKey:@"State"];
                        airport.ident = [airportDict valueForKey:@"Identifier"];
                        [airportsTemp addObject:airport];
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    else
    {
        return;
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
    
    [self.tableView reloadData];
    
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if ([[self.airports objectAtIndex:section] count] > 0)
    {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.airports count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.airports objectAtIndex:section] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteAirports"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier=%@)", airportObj.ident];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        
        NSManagedObject *newFavAirport = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteAirports" inManagedObjectContext:self.context];
    
        [newFavAirport setValue:airportObj.name forKey:@"name"];
        [newFavAirport setValue:airportObj.city forKey:@"city"];
        [newFavAirport setValue:airportObj.state forKey:@"state"];
        [newFavAirport setValue:airportObj.ident forKey:@"identifier"];
    
        NSError *error;
    
        if(![self.context save:&error])
        {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to save favorite" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [error show];
            return;
        }
        else
        {
            UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Favorite Added" message:[NSString stringWithFormat:@"%@ has been added to your favorite airports", airportObj.name] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [msg show];
        }
        
    }
    else if(editingStyle == UITableViewCellEditingStyleDelete)
    {
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
        
        [self performSegueWithIdentifier:@"segueAirportDetail" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"segueCheckFlightStatus" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    CheckFlightStatus *previousView = [[self.navigationController viewControllers] objectAtIndex:1];
    NSIndexPath *selCellPath = self.tableView.indexPathForSelectedRow;
    AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:selCellPath.section] objectAtIndex:selCellPath.row];
    
    if([segue.identifier isEqualToString:@"segueCheckFlightStatus"])
    {
        
        UITableViewCell *selCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        if([previousView.singletonObj.destOrOriginSelected isEqualToString:@"Origin"])
        {
            previousView.singletonObj.selectedOriginIdent = airportObj.ident;
            previousView.singletonObj.selectedOriginAirport = selCell.textLabel.text;
        }
        else
        {
            previousView.singletonObj.selectedDestinationIdent = airportObj.ident;
            previousView.singletonObj.selectedDestinationAirport = selCell.textLabel.text;
        }
    
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loadTableData];
}

- (void)viewDidUnload {
    [self setBtnEdit:nil];
    [super viewDidUnload];
}
- (IBAction)doEdit:(id)sender
{
    if(self.tableView.editing)
    {
        self.btnEdit.title = @"Favorites";
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        self.btnEdit.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}
@end
