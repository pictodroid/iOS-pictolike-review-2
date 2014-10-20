//
//  SavedViewController.h
//  Pictolike
//
//  Created by Emil Izgin on 17/10/14.
//
//

#import <UIKit/UIKit.h>
#import "MyDatabaseManager.h"
#import <Parse/Parse.h>
#import "Person.h"
#import "MyDatabaseManager.h"

@interface SavedViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {

    NSTimer *starAnimationTimer;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonStar;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) IBOutlet UIButton *refreshButton;

- (IBAction)starAction:(id)sender;

- (IBAction)refreshAction:(id)sender;

@end
