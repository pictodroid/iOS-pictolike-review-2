//
//  SignUpViewController.m
//  Star App
//
//  Created by Iftekhar on 08/10/14.
//  Copyright (c) 2014 Indresh. All rights reserved.
//

#import "SignUpViewController.h"
#import "PLTextField.h"
#import "PLUtility.h"
#import "PLTabViewController.h"
#import "IQDropDownTextField.h"

@interface SignUpViewController ()<UITextViewDelegate>

@end

@implementation SignUpViewController
{
    __weak IBOutlet PLTextField *textFieldEmail;
    __weak IBOutlet PLTextField *textFieldPassword;
    __weak IBOutlet IQDropDownTextField *textFieldBirthday;
    __weak IBOutlet UIButton *buttonMale;
    __weak IBOutlet UIButton *buttonFemale;
    
//<<<<<<< HEAD
    NSString* gender;
    int age;
//=======
    __weak IBOutlet UITextView *textViewAgreement;
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setting birth date picker.
    {
        textFieldBirthday.dropDownMode = IQDropDownModeDatePicker;
        textFieldBirthday.minimumDate = [NSDate dateWithTimeIntervalSince1970:-2208988800]; //1 Jan 1900
        textFieldBirthday.maximumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0]; //1 Jan 2001
        textFieldBirthday.date = [NSDate dateWithTimeIntervalSince1970:824428800];  //16 Feb 1996
    }
    
    //Setting hyperlink attributedString.
    {
        textViewAgreement.textContainer.lineFragmentPadding = 0;
        textViewAgreement.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        NSMutableAttributedString *stringAgreement = [[NSMutableAttributedString alloc] initWithString:@"By creating an account, you agree to the Terms of Use and you acknowledge that you have read the Privacy Policy." attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        NSRange rangeTermsOfUse = [stringAgreement.string rangeOfString:@"Terms of Use" options:NSCaseInsensitiveSearch];
        if (rangeTermsOfUse.location != NSNotFound)
        {
            [stringAgreement addAttribute: NSLinkAttributeName value:[NSURL URLWithString:@"http://pictolikeapp.com/terms.html"] range:rangeTermsOfUse];
            [stringAgreement addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:rangeTermsOfUse];
        }
        
        NSRange rangePrivacyPolicy = [stringAgreement.string rangeOfString:@"Privacy Policy" options:NSCaseInsensitiveSearch];
        if (rangePrivacyPolicy.location != NSNotFound)
        {
            [stringAgreement addAttribute: NSLinkAttributeName value:[NSURL URLWithString:@"http://pictolikeapp.com/privacy.html" ] range:rangePrivacyPolicy];
            [stringAgreement addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:rangePrivacyPolicy];
        }
        
        textViewAgreement.attributedText = stringAgreement;

        //By creating an account, you agree to the Terms of Use and you acknowledge that you have read the Privacy Policy.
    }
    
//>>>>>>> FETCH_HEAD
}

- (IBAction)signupAction:(UIButton *)sender
{
    if ([textFieldBirthday.text length] > 0) {
        
    }
    
    if ([textFieldEmail.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldEmail.text isValidateEmail] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please enter valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldPassword.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Password can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldBirthday.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Birthday can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if ([textFieldBirthday.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Birthday can't be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (buttonMale.tag == 0 && buttonFemale.tag == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please select gender" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
//<<<<<<< HEAD
        if (buttonMale.tag == 1) {
            gender = @"Male";
        } else {
            gender = @"Female";
        }
        [self saveNewUser:textFieldEmail.text :textFieldPassword.text :[NSDate date] :gender];

//=======
        //Date components may be access via
        NSLog(@"Day: %d,Month: %d,Year: %d",textFieldBirthday.day, textFieldBirthday.month, textFieldBirthday.year);
        
//>>>>>>> FETCH_HEAD
        [self performSegueWithIdentifier:NSStringFromClass([PLTabViewController class]) sender:self];
    }
}

- (IBAction)maleButtonAction:(UIButton *)sender
{
    buttonMale.tag = 1;
    buttonFemale.tag = 0;
    
    [buttonMale setImage:[UIImage imageNamed:@"Male-Selected"] forState:UIControlStateNormal];
    [buttonFemale setImage:[UIImage imageNamed:@"Female-Normal"] forState:UIControlStateNormal];
}

- (IBAction)femaleButtonAction:(UIButton *)sender
{
    buttonMale.tag = 0;
    buttonFemale.tag = 1;
    
    [buttonMale setImage:[UIImage imageNamed:@"Male-Normal"] forState:UIControlStateNormal];
    [buttonFemale setImage:[UIImage imageNamed:@"Female-Selected"] forState:UIControlStateNormal];
}

//<<<<<<< HEAD

-(bool) saveNewUser: (NSString*)email :(NSString*)password :(NSDate*)birthday :(NSString*)gender {
//    @property (nonatomic, retain) NSString * email;
//    @property (nonatomic, retain) NSString * password;
//    @property (nonatomic, retain) NSString * username;
//    @property (nonatomic, retain) NSDate * birthday;
//    @property (nonatomic, retain) NSNumber * age;
//    @property (nonatomic, retain) NSString * gender;
    NSString *userName = [[email stringByReplacingOccurrencesOfString:@"@" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSDictionary *dict = @{@"email": email,
                           @"password":password,
                           @"username":userName,
                           @"birthday":birthday,
                           @"age":@0,
                           @"gender":gender
                           };
    
    [[MyDatabaseManager sharedManager] insertRecordInUser:dict];

    PFObject *userObject = [PFObject objectWithClassName:@"User"];
    [userObject setObject:email forKey:@"email"];
    [userObject setObject:password forKey:@"password"];
    [userObject setObject:userName forKey:@"userName"];
    [userObject setObject:birthday forKey:@"birthday"];
    [userObject setObject:[NSNumber numberWithInt:20] forKey:@"age"];
    [userObject setObject:gender forKey:@"gender"];
    [userObject saveInBackground];
    
    return YES;
}
    
//=======
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
//>>>>>>> FETCH_HEAD
    return YES;
}

@end
