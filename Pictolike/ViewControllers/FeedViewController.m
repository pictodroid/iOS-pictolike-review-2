//
//  ViewController.m
//  Star App
//
//  Created by Indresh on 07/09/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCell.h"
#import "MyDatabaseManager.h"

@interface FeedViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate>
{
    IBOutlet UICollectionView *collectionViewFeed;
    IBOutlet UIButton *buttonStar;

    NSArray *feeds;
    
    NSUInteger totalRecords;
    NSTimer *starAnimationTimer;
}

@end

@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    feeds = [[MyDatabaseManager sharedManager] allFeeds];

    totalRecords = feeds.count;
    
    //If No feed then Initially insert 9 data in core data
    if (feeds.count == 0)
    {
        [self appendDummyFeedIfNeeded];
    }
    else
    {
        feeds = [feeds subarrayWithRange:NSMakeRange(0, 9)];
    }
}

-(IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gestureRecognizer locationInView:collectionViewFeed];
        
        NSIndexPath *indexPath = [collectionViewFeed indexPathForItemAtPoint:point];
        if (indexPath)
        {
//            UICollectionViewCell* cell = [collectionViewFeed cellForItemAtIndexPath:indexPath];

            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
            [actionSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Message" message:@"Deleting feed is not implemented yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(void)appendDummyFeedIfNeeded
{
    if (totalRecords <= feeds.count)
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
    
    feeds = [[[MyDatabaseManager sharedManager] allFeeds] subarrayWithRange:NSMakeRange(0, feeds.count+9)];

    [collectionViewFeed reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return feeds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FeedCell class]) forIndexPath:indexPath];
    
    FeedTable *feed = [feeds objectAtIndex:indexPath.row];
    
    cell.imageViewFeed.image = feed.image;
    cell.labelCount.text = [NSString stringWithFormat:@"%@",feed.likes];
 
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 120);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (IBAction)starAction:(UIButton *)sender
{
    if (starAnimationTimer)
    {
        [[NSRunLoop currentRunLoop] addTimer:starAnimationTimer forMode:NSDefaultRunLoopMode];
        [starAnimationTimer invalidate];
        starAnimationTimer = nil;
    }
    else
    {
        starAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(animateStar:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:starAnimationTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)animateStar:(NSTimer*)timer
{
    buttonStar.transform = CGAffineTransformRotate(buttonStar.transform, M_PI*(1.0/180.0));
}

- (IBAction)refreshAction:(UIButton *)sender
{
    [self appendDummyFeedIfNeeded];
}

@end


