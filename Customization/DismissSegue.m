//
//  DismissSegue.m
//  Pictolike
//
//  Created by Emil Izgin on 17/10/14.
//
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
