//
//  ViewController.h
//  CollectionViewExample
//
//  Created by Tim on 9/5/12.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDatabaseManager.h"
#import <Parse/Parse.h>
#import "Person.h"

@interface ProfViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
- (IBAction)refreshAction:(id)sender;

@end
