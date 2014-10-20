//
//  ProfileClases.h
//  Pictolike
//
//  Created by Shikha Kamboj on 8/4/14.
//  Copyright (c) 2014 web. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDatabaseManager.h"
#import <Parse/Parse.h>
#import "Person.h"

@interface ProfileClases : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate> {
//    IBOutlet UICollectionView *collectionViewFeed;    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//@property (weak, nonatomic) IBOutlet UIImageView *uiImageView;
//@property (weak, nonatomic) IBOutlet UILabel *Label;
//@property (weak, nonatomic) IBOutlet UIImageView *icon_imageView;

- (IBAction)RefreshBtnAction:(id)sender;

@end
