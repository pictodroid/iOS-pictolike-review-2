//
//  ProfileClases.m
//  Pictolike
//
//  Created by Shikha Kamboj on 8/4/14.
//  Copyright (c) 2014 web. All rights reserved.
//

#import "ProfileClases.h"
#import "ProfileCell.h"

@interface ProfileClases ()

@end

@implementation ProfileClases

NSMutableArray *persons;
NSUInteger totalRecords;

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
    
//    feeds = [[MyDatabaseManager sharedManager] allFeeds];
    
//    totalRecords = feeds.count;
    [self.collectionView registerClass:[ProfileCell class] forCellWithReuseIdentifier:@"profileCell"];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    
    PFQuery *qMyPicts = [PFQuery queryWithClassName:@"Picto"];
    //    [qUid whereKey:@"password" equalTo: textFieldPassword.text];
    [qMyPicts whereKey:@"username" equalTo: [userDefaults objectForKey:@"userName"]];
    __block NSArray *myPicts;
    myPicts = [qMyPicts findObjects];
    
    if ([myPicts count] < 1) {
//        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"No pictures" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    //        for (PFObject *object in newUser) {
    //            NSLog(@"%@", object.objectId);
    //        }
    //    NSString* emailAddress;
    //    NSString* userName;
    persons = [[NSMutableArray alloc] init];
    
    for (PFObject *object in myPicts) {
        //        PFObject *eachObject = [images objectAtIndex:i];
        PFFile *theImage = [object objectForKey:@"imageobj"];
        NSData *imageData = [theImage getData];
        UIImage *imageFromPFObject = [UIImage imageWithData:imageData];
        
        
        [persons addObject:[[Person alloc] initWithName:[object objectForKey:@"username"]
                                                  image:imageFromPFObject
                                                    age:15
                                  numberOfSharedFriends:3
                                numberOfSharedInterests:2
                                         numberOfPhotos:1]];
        //        emailAddress = [object objectForKey:@"email"];
        //        userName = [object objectForKey:@"userName"];
        
    }
    
    totalRecords = [persons count];
    if (totalRecords < 1) {
//        [self appendDummyFeedIfNeeded];
    } else {
//        persons = [persons subarrayWithRange:NSMakeRange(0, 9)];
    }
    
    // Do any additional setup after loading the view.
}


-(void)appendDummyFeedIfNeeded
{
    if (totalRecords <= persons.count)
    {
        for (NSInteger i = 0; i<9; i++)
        {
            NSUInteger random = arc4random();
            random = random%100;
            
            NSDictionary *dict = @{@"image": [UIImage imageNamed:(random%2)?@"SingleLIkeStar@High.png":@"ReportButton.png"],
                                   @"user":@"user",
                                   @"likes":@(random),
                                   @"date":[NSDate date]};
            
            [[MyDatabaseManager sharedManager] insertRecordInFeedTable:dict];
        }
    }
    
    persons = [[[MyDatabaseManager sharedManager] allFeeds] subarrayWithRange:NSMakeRange(0, persons.count+9)];
    
//    [collectionViewFeed reloadSections:[NSIndexSet indexSetWithIndex:0]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark  collection view delegate.

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
    
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [persons count];  // 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    //cell.imageview.image= [UIImage imageNamed:@"no_img.png"];
    
//    ProfileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ProfileCell class]) forIndexPath:indexPath];
    ProfileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profileCell" forIndexPath:indexPath];
    
    Person *feed = [persons objectAtIndex:indexPath.row];
    
    cell.imageview.image = feed.image;
    cell.icon_imageview.image = [UIImage imageNamed:@"SingleLIkeStar@High.png"];
//    cell.imageViewFeed.image = feed.image;
    cell.label.text = [NSString stringWithFormat:@"%lu",(unsigned long)feed.numberOfSharedFriends];
//    cell.labelCount.text = [NSString stringWithFormat:@"%@",feed.likes];
    
    return cell;
}

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor colorWithPatternImage:[self.results objectAtIndex:indexPath.row]];
//    return cell;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    
//    return 5;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 120);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (IBAction)RefreshBtnAction:(id)sender {
    
    
}


@end
