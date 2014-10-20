//
//  LoginViewController.m
//  Star App
//
//  Created by Iftekhar on 08/10/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "LoginViewController.h"
#import "PLTextField.h"
#import "PLUtility.h"
#import "PLTabViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    __weak IBOutlet PLTextField *textFieldEmail;
    __weak IBOutlet PLTextField *textFieldPassword;

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)loginAction:(UIButton *)sender
{
    if ([textFieldEmail.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldEmail.text isValidateEmail] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please enter valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldPassword.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Password can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        PFQuery *qUid = [PFQuery queryWithClassName:@"User"];
        [qUid whereKey:@"password" equalTo: textFieldPassword.text];
        [qUid whereKey:@"email" equalTo: textFieldEmail.text];
        __block NSArray *newUser;
        newUser = [qUid findObjects];

        if ([newUser count] < 1) {
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email or password is not correct" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
//        for (PFObject *object in newUser) {
//            NSLog(@"%@", object.objectId);
//        }
        NSString* emailAddress;
        NSString* userName;
        for (PFObject *object in newUser) {
            emailAddress = [object objectForKey:@"email"];
            userName = [object objectForKey:@"userName"];
        }
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        [userDefaults setObject:emailAddress forKey:@"email"];
        [userDefaults setObject:userName forKey:@"userName"];


        [self performSegueWithIdentifier: @"FromSigninToTabBarSegue" sender:self]; //] NSStringFromClass([PLTabViewController class]) sender:self];
    }
}


@end
