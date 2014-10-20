//
//  ViewController.m
//  Pictolike
//
//  Created by Shikha Kamboj on 7/31/14.
//  Copyright (c) 2014 web. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"

@interface ViewController ()<ViewPagerDataSource,ViewPagerDelegate>
@property (nonatomic) NSInteger numberOfTabs;
@end

@implementation ViewController




- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:3.0];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;

    
    // [self addToolbar];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


#pragma mark - Setters
- (void)setNumberOfTabs:(NSUInteger)numberOfTabs
{
    
    // Set numberOfTabs
    _numberOfTabs = numberOfTabs;
    
    // Reload data
    [self reloadData];
    
}




- (void)loadContent {
    self.numberOfTabs = 4;
}




#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return self.numberOfTabs;
}


- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    NSString *imagename = [NSString stringWithFormat:@"tabbarbtn%lu.png", (unsigned long)index];
    UIImageView *brickAnim  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 32, 32)];
    [brickAnim setImage:[UIImage imageNamed:imagename]];

//  UIImageView *brickAnim = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagename]];

//    UILabel *label = [UILabel new];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont systemFontOfSize:12.0];
//    label.text = [NSString stringWithFormat:@"Tab #%i", index];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor blackColor];
//    [label sizeToFit];
    return brickAnim;
}


- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    CameraViewController *cvc;// = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    
   // cvc.labelstring = [NSString stringWithFormat:@"Content View #%i", index];
    if (index == 0){
        
        cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    }
    else if (index == 1){
      
        cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    
    }
    else if (index == 2){
    
        cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileClases"];
    }
    else if (index ==3){
    
        cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    }
    
    else if (index ==4){
        
        cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    }
    
    return cvc;
}


#pragma mark - ViewPagerDelegate

//- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value
//{
//    
////        switch (option)
////    {
////       
////        case ViewPagerOptionStartFromSecondTab:
////            return 0.0;
////        case ViewPagerOptionCenterCurrentTab:
////            return 0.0;
////        case ViewPagerOptionTabLocation:
////            return 1.0;
////        case ViewPagerOptionTabHeight:
////            return 49.0;
////        case ViewPagerOptionTabOffset:
////            return 36.0;
////        case ViewPagerOptionTabWidth:
////            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0 : 96.0;
////        case ViewPagerOptionFixFormerTabsPositions:
////            return 1.0;
////        case ViewPagerOptionFixLatterTabsPositions:
////            return 1.0;
////        default:
////            return value;
////    
////    }
//}
//

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor whiteColor] colorWithAlphaComponent:0.64];
        case ViewPagerTabsView:
           // return [UIColor colorWithPatternImage:[UIImage imageNamed:@"HomeButton32@High.png"]];
        case ViewPagerContent:
            return [[UIColor darkGrayColor] colorWithAlphaComponent:0.32];
        default:
            return color;
    }
}


# pragma mark  add Tool bar button

-(void)addToolbar

{
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    
    UIBarButtonItem *customItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeButton32@High.png"] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarItem2:)];
    
    UIBarButtonItem *customItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CameraButton32@High.png"] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarItem2:)];

    
    UIBarButtonItem *customItem3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ProfileButton32@High.png"] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarItem2:)];
    
    
    UIBarButtonItem *customItem4 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingButton32@High.png"] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarItem2:)];
   
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             customItem1,spaceItem, customItem2, spaceItem, customItem3, spaceItem, customItem4, nil];
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"TopBar.png"]
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, 0, 320, 50)];
    
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    
    [self.view addSubview:toolbar];
    
    [toolbar setItems:toolbarItems];
    
}


# pragma mark  Tool Bar buttons action.

-(IBAction)toolBarItem1:(id)sender{
    
}

-(IBAction)toolBarItem2:(id)sender{
    
}

-(IBAction)ToolBarItem3:(id)sender{
   
}



@end
