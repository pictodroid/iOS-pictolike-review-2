//
//  SignUpViewController.h
//  Star App
//
//  Created by Iftekhar on 08/10/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDatabaseManager.h"
#import <Parse/Parse.h>

@interface SignUpViewController : UIViewController

-(bool) saveNewUser: (UIImage*)image;

@end
