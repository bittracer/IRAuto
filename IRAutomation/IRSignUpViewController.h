//
//  IRSignUp.h
//  IRAutomation
//
//  Created by bharat jain on 2/19/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRKeys.h>

@interface IRSignUpViewController : UIViewController <UITextFieldDelegate>
{
    NSArray *textFieldLeftView;
    NSArray *textFieldName;
    UIImageView *imgview ;
    NSArray *columnName;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *activeField;
@property (weak, nonatomic) IBOutlet UITextField *txtfname;
@property (weak, nonatomic) IBOutlet UITextField *txtlname;
@property (weak, nonatomic) IBOutlet UITextField *txtcontact;
@property (weak, nonatomic) IBOutlet UITextField *txtemail;
@property (weak, nonatomic) IBOutlet UITextField *txtpass;
@property (weak, nonatomic) IBOutlet UITextField *txtconfpass;
@property (weak, nonatomic) IBOutlet UIButton *btnPressed;
@property (nonatomic) IRKeys *keys;

- (IBAction)signUpBtnPressed;
- (NSString *)validateForm ;
- (void)setLeftView;
//- (void)moveKeyboardUp;
//- (void)moveKeyboardDown;
- (IBAction)cancelBtnPressed:(id)sender;
- (void)uploadOnParseCloud;

@end


