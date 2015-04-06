//
//  IRSignUp.m
//  IRAutomation
//
//  Created by bharat jain on 2/19/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRSignUpViewController.h"
#import "NSString+FormValidation.h"
#import "constant.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "IRDBManager.h"
#import <Parse/Parse.h>


@interface IRSignUpViewController ()


@end

@implementation IRSignUpViewController

#pragma mark - UIViewController Lifecycle Methods


- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    //Will call LeftView Method
   
    [self setLeftView];
     [self registerForKeyboardNotifications];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}



#pragma mark - Button Action Events

//This will display alert if data entered not equal to the required format

- (IBAction) signUpBtnPressed{
    
    //will call validateForm method
    NSString *errorMessage = [self validateForm];

    
    //Will check for the Input format
    if (errorMessage) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        return;
    }
    else{

        _loading.hidden = NO;
        [_loading startAnimating];
        [self performSelector:@selector(uploadOnParseCloud) withObject:nil afterDelay:0.6];

    }
    
}

- (IBAction)cancelBtnPressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
  

}


//The below is the validation for signup and regex is placed in the catogery NSString+FormValidation

- (NSString *) validateForm {
    NSString *errorMessage;
    

    
    if(!((self.txtfname.text.length)==(self.txtlname.text.length)==(self.txtcontact.text.length)==(self.txtemail.text.length)==(self.txtpass.text.length)==(self.txtconfpass.text.length))==0){
        errorMessage =ALL_TEXTFIELD_EMPTY ;
       
    }
    else if (![self.txtfname.text isValidString]){
        errorMessage = FNAME_ERROR;
    }
    else if (![self.txtlname.text isValidString]){
           errorMessage = LNAME_ERROR;
    }
    else if (![self.txtcontact.text isValidContact]){
        
        errorMessage = CONTACT_ERROR;
    }
    else if (![self.txtemail.text isValidEmail]){
        errorMessage = EMAIL_ERROR;
    }
    else if (![self.txtpass.text isValidPassword]){
        errorMessage = PWD_ERROR;
    }
    else if (![self.txtpass.text isEqualToString:self.txtconfpass.text]){
        errorMessage = PWDL_ERROR;
    }
    
    [_txtconfpass resignFirstResponder];
    
    return errorMessage;
}



// will set leftView

-(void) setLeftView{
    
        // Array of Images
        textFieldLeftView = @[@"user_icn-Small", @"user_icn-Small", @"contact_icn-Small", @"email_icn-Small", @"pass_icn-Small",@"pass_icn-Small"];
    
        //Array of TextField
        textFieldName =@[_txtfname,_txtlname,_txtcontact,_txtemail,_txtpass,_txtconfpass];

    for(int i=0;i< [textFieldName count];i++){
    
        imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, 43)];
        // Takes images one by one
        [imgview setImage:[UIImage imageNamed:textFieldLeftView[i]]];
        [imgview setContentMode:UIViewContentModeScaleAspectFit];
        //[imgview sizeThatFits:CGSizeMake(37, 43)];

        //Set images one by one (leftview is the property of textfield so typecast)
        
        ((UITextField *)textFieldName[i]).leftView = imgview;
        ((UITextField *)textFieldName[i]).leftViewMode = UITextFieldViewModeAlways;
        
        //((UITextField *)textFieldName[i]).layer.sublayerTransform = CATransform3DMakeTranslation(35,0,0);
        [((UITextField *)textFieldName[i]).layer setBorderWidth:1.5 ];
        [((UITextField *)textFieldName[i]).layer setBorderColor:SELF_DEFINED];

    }
  
}


-(void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
}

// This will upload the data on parse cloud
- (void)uploadOnParseCloud{
    
    
    PFUser *user = [PFUser user];
    user.username = _txtemail.text;
    user.password = _txtpass.text;
    user.email = _txtemail.text;
    
    textFieldName =@[_txtfname,_txtlname,_txtcontact,_txtconfpass];
    
    columnName=@[@"FirstName",@"Lastname",@"contact",@"confirmpassword"];
    
    NSString *str;

    for(int i=0;i<[textFieldName count]; i++){
        
        str=columnName[i];
        user[str] = ((UITextField *)textFieldName[i]).text;
        
    }
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [_loading stopAnimating];
        if (!error) {
            
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@" Successfully Registered" message:@"Please Sign In to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:errorString delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            // Show the errorString somewhere and let the user try again.
            
        }
    }];
    

}


#pragma mark - Text Field delegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _txtfname) {
        [_txtlname becomeFirstResponder];
      //  [self moveKeyboardUp];
    } else if (theTextField == _txtlname) {
        [_txtcontact becomeFirstResponder];
        //[self moveKeyboardUp];
    } else if( theTextField == _txtcontact){
         [_txtemail becomeFirstResponder];
        //[self moveKeyboardUp];
    }else if (theTextField == _txtemail){
        [_txtpass becomeFirstResponder];
       // [self moveKeyboardUp];
    }else if (theTextField == _txtpass){
        [_txtconfpass becomeFirstResponder];
       // [self moveKeyboardUp];
    }else if (theTextField ==_txtconfpass){
       // [self resignFirstResponder];
        [_txtconfpass becomeFirstResponder];
        [self signUpBtnPressed];
    }
    return YES;
}



- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect,_activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:_activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

//- (void) moveKeyboardUp{
//    
//    // move the view up by 30 pts
//    CGRect frame = self.view.frame;
//    if(frame.size.height >400){
//    frame.origin.y += -10;
//    }else{
//         frame.origin.y += -30;
//    }
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = frame;
//    }];
//}
//
//- (void) moveKeyboardDown{
//    
//    // Make everything Normal
//    CGRect frame = self.view.frame;
//    frame.origin.y = 0;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = frame;
//    }];
//}

@end
