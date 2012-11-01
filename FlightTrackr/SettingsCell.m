//
//  SettingsCell.m
//  FlightTrackr
//
//  Created by Unbounded on 10/26/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "SettingsCell.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.appDelegate = [[UIApplication sharedApplication] delegate];
        self.context = [self.appDelegate managedObjectContext];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)doReset:(id)sender
{
    
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"This will erase all of your favorites" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [confirm show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 1)
    {
        
        [self.appDelegate resetCoreData];
        [self.appDelegate resetPersistentStore];
        
        UIAlertView *done = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Data has been sucessfully reset" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [done show];
    }
    
}
@end
