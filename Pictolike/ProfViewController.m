//
//  ProfViewController.m
//  CollectionViewExample
//
//  Created by
//

#import "ProfViewController.h"
#import "CVCell.h"

@interface ProfViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ProfViewController

NSMutableArray *persons;
NSUInteger totalRecords;

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"profileCell"];
    
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
                                  numberOfSharedFriends:[[object objectForKey:@"noOfLikes"] intValue]
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
    
/*
    // Create data for collection views
    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
    
    for (int i=0; i<50; i++) {
        [firstSection addObject:[NSString stringWithFormat:@"Cell %d", i]];
        [secondSection addObject:[NSString stringWithFormat:@"item %d", i]];
    }

    self.dataArray = [[NSArray alloc] initWithObjects:firstSection, secondSection, nil];
   */
    
    /* Uncomment this block to use nib-based cells */
    //UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    //[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    /* end of nib-based cells block */
    /* uncomment this block to use subclassed cells */
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    /* end of subclass-based cells block */
    
    // Configure layout
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(87, 124)];
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    self.collectionView = nil;
//    self.dataArray = nil;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return [self.dataArray count];
    return 1;

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

//    NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
//    return [sectionArray count];
    return [persons count];  // 9;


}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell identifier
    static NSString *cellIdentifier = @"cvCell";

    /*  Uncomment this block to use nib-based cells */
    // UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    // UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    // [titleLabel setText:cellData];
    /* end of nib-based cell block */
    
    /* Uncomment this block to use subclass-based cells */
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSMutableArray *data = [self.dataArray objectAtIndex:indexPath.section];
    NSString *cellData = [data objectAtIndex:indexPath.row];
    [cell.titleLabel setText:cellData];
    /* end of subclass-based cells block */
    Person *feed = [persons objectAtIndex:indexPath.row];

    cell.Label.text = [NSString stringWithFormat:@"%lu",(unsigned long)feed.numberOfSharedFriends];
    cell.imageview.image = feed.image;
    cell.icon_imageview.image = [UIImage imageNamed:@"SingleLIkeStar@High.png"];
 
    // Return the cell
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 120);
}


- (IBAction)refreshAction:(id)sender {
}
@end
