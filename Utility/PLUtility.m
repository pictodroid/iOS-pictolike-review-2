//
//  PLUtility.m
//  Star App
//
//  Created by Iftekhar on 08/10/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "PLUtility.h"

@implementation PLUtility

@end

@implementation NSString (Validation)

- (BOOL)isValidateEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end

