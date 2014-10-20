//
//  FeedCell.h
//  Star App
//
//  Created by Indresh on 08/09/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewFeed;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewStarIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelCount;

@end
