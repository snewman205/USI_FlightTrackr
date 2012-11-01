//
//  DoneCancelNumberPadToolbar.h
//  IT Tracker
//
//  Created by User on 10/23/12.
//  Copyright (c) 2012 Jose M. Soto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DoneCancelNumberPadToolbar;

@protocol DoneCancelNumberPadToolbarDelegate <NSObject>

-(void)doneCancelNumberPadToolbarDelegate:(DoneCancelNumberPadToolbar *)controller didClickDone:(UITextField *)textField;
-(void)doneCancelNumberPadToolbarDelegate:(DoneCancelNumberPadToolbar *)controller didClickCancel:(UITextField *)textField;

@end

@interface DoneCancelNumberPadToolbar : UIToolbar
{
    UITextField* textField;
}
@property (nonatomic, weak) id <DoneCancelNumberPadToolbarDelegate> delegate;

- (id) initWithTextField:(UITextField *)textField;



@end