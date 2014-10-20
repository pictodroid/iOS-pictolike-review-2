//
//  PLTextField.m
//  Star App
//
//  Created by Iftekhar on 08/10/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "PLTextField.h"

@implementation PLTextField

-(void)initialize
{
    self.borderStyle = UITextBorderStyleNone;
    self.background = [UIImage imageNamed:@"Box"];
    
    self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
    self.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
    
    self.leftView.backgroundColor = [UIColor clearColor];
    self.rightView.backgroundColor = [UIColor clearColor];
    
    self.leftViewMode = UITextFieldViewModeAlways;
    self.rightViewMode = UITextFieldViewModeAlways;
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


@end
