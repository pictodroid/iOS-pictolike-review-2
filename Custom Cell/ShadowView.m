//
//  ShadowView.m
//  Star App
//
//  Created by Indresh on 08/09/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "ShadowView.h"

@implementation ShadowView

-(void)initialize
{
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 0;
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 0.5;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

@end
