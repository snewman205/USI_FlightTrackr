//
//  AirportLocalPlaceDetail.m
//  FlightTrackr
//
//  Created by Unbounded on 10/24/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportLocalPlaceDetail.h"

@interface AirportLocalPlaceDetail ()

@end

@implementation AirportLocalPlaceDetail

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
}

- (void)viewDidAppear:(BOOL)animated
{
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    self.addressComponents = [[NSArray alloc] init];
    self.phone = [[NSString alloc] init];
    self.name = [[NSString alloc] init];
    self.streetNo = [[NSString alloc] init];
    self.street = [[NSString alloc] init];
    self.city = [[NSString alloc] init];
    self.state = [[NSString alloc] init];
    self.zip = [[NSString alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", [singletonObj readValues], GOOGLE_API_KEY];
    
    NSURL *requestURL = [NSURL URLWithString:url];
    
    self.dataReturned = NO;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.activityIndicatorOn = YES;
    hud.topText = @"Processing";
    hud.bottomText = @"Please wait...";
    [hud showInView:self.view];
    
    dispatch_async(kBgQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:requestURL];
                       [self performSelectorOnMainThread:@selector(dataFetched:) withObject:data waitUntilDone:YES];
                   });

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
    return (self.dataReturned) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (self.dataReturned) ? 3 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Assign section headers
    return (self.dataReturned) ? [self.sectionHeaders objectAtIndex:section] : NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Address:";
        
        for(NSDictionary *dict in self.addressComponents)
        {
            NSArray *componentTypes = [dict objectForKey:@"types"];
            
            for (NSString *key in componentTypes)
            {
                if([key isEqualToString:@"street_number"])
                {
                    self.streetNo = [dict valueForKey:@"long_name"];
                }
                else if([key isEqualToString:@"route"])
                {
                    self.street = [dict valueForKey:@"long_name"];
                }
                else if([key isEqualToString:@"locality"])
                {
                    self.city = [dict valueForKey:@"long_name"];
                }
                else if([key isEqualToString:@"administrative_area_level_1"])
                {
                    self.state = [dict valueForKey:@"long_name"];
                }
                else if([key isEqualToString:@"postal_code"])
                {
                    self.zip = [dict valueForKey:@"long_name"];
                }
            }
        }
                           
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@\n%@, %@ %@", self.streetNo, self.street, self.city, self.state, self.zip];
    
    }
    else if(indexPath.row == 2)
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cell.textLabel.text = @"Phone:";
        cell.detailTextLabel.text = self.phone;
    }
    
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"Directions";
        cell.detailTextLabel.text = @"";
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)dataFetched:(NSData*)response
{
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSDictionary *resultObj = [jsonData objectForKey:@"result"];
    
    if(error)
    {
        NSLog(@"Danger Will Robinson, DANGER!");
    }
    
    self.addressComponents = [resultObj objectForKey:@"address_components"];
    self.phone = [resultObj valueForKey:@"formatted_phone_number"];
    self.name = [resultObj valueForKey:@"name"];
    self.sectionHeaders = [NSArray arrayWithObjects:self.name,nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    
    [self.lblTTC setHidden:NO];
    self.dataReturned = YES;
    [self.tableView reloadData];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    if(indexPath.row == 2)
    {
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.phone]]];
        } else {
            UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [Notpermitted show];
        }
    }
    else if(indexPath.row == 1)
    {
        NSURL *launchURL = [NSURL URLWithString:[[NSString stringWithFormat:@"https://maps.google.com/maps?saddr=%@&daddr=%@ %@ %@, %@ %@&hl=en", singletonObj.airportGoogleAddress, self.streetNo, self.street, self.city, self.state, self.zip] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"url - %@", launchURL);
        
        [[UIApplication sharedApplication] openURL:launchURL];
    }
}

- (void)viewDidUnload {
    [self setLblTTC:nil];
    [super viewDidUnload];
}
@end
