//
//  DoneCancelNumberPadToolbar.m
//  IT Tracker
//
//  Created by User on 10/23/12.
//  Copyright (c) 2012 Jose M. Soto. All rights reserved.
//
#import "DoneCancelNumberPadToolbar.h"

@implementation DoneCancelNumberPadToolbar

@synthesize delegate;

- (id) initWithTextField:(UITextField *)aTextField
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 50)];
    if (self) {
        textField = aTextField;
        self.barStyle = UIBarStyleBlackTranslucent;
        self.items = [NSArray arrayWithObjects:
                      [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil action:nil],
                      [[UIBarButtonItem alloc]initWithTitle:@"Done"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(doneWithNumberPad:)],
                      nil];
        [self sizeToFit];
        
    }
    return self;
}

-(void)cancelNumberPad: (id) sender
{
    [textField resignFirstResponder];
    textField.text = @"";
    [self.delegate doneCancelNumberPadToolbarDelegate:self didClickCancel:textField];
}

-(void)doneWithNumberPad: (id) sender
{
    [textField resignFirstResponder];
    [self.delegate doneCancelNumberPadToolbarDelegate:self didClickDone:textField];
}
@end


