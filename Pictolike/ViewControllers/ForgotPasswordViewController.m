//
//  ForgotPasswordViewController.m
//  Star App
//
//  Created by Iftekhar on 08/10/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "PLTextField.h"
#import "PLUtility.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController
{
    __weak IBOutlet PLTextField *textFieldEmail;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)submitAction:(UIButton *)sender
{
    if ([textFieldEmail.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldEmail.text isValidateEmail] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please enter valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
