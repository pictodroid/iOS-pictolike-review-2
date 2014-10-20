//
//  CameraViewController.h
//  Pictolike
//
//  Created by Shikha Kamboj on 8/1/14.
//  Copyright (c) 2014 web. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDatabaseManager.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface CameraViewController : UIViewController

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;
@property (strong, nonatomic) CLLocation *currntLocation;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (strong, nonatomic) IBOutlet UIButton *snapButton;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;

@property (strong, nonatomic) IBOutlet UIButton *pButton;
-(bool) saveImage: (UIImage*)image;

@end
