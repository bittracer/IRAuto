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
#import "IRRootView.h"


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
            
            AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDel userLogin:@"IRRootView"];
        
//            [self.navigationController popToRootViewControllerAnimated:YES];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@" Successfully Registered" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

-(void)textFieldDidBeginEditing:(UITextField *)textField{
  
    [self createInputAccessoryView:textField];
    
    // Now add the view as an input accessory view to the selected textfield.
    [textField setInputAccessoryView:_inputAccView];
    
    // Set the active field. We' ll need that if we want to move properly
    // between our textfields.
    _activeField = textField;
}


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

#pragma InputAccesoryview

-(void)createInputAccessoryView:(UITextField *)actextfield{
    // Create the view that will play the part of the input accessory view.
  
    _inputAccView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];
    
    // Set the view’s background color. We’ ll set it here to gray. Use any color you want.
    [_inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [_inputAccView setAlpha: 0.8];
    
    
   //  the previous button.
    if (_activeField != _txtfname) {
        
        _btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
        [_btnPrev setFrame: CGRectMake(30.0, 0.0, 80.0, 40.0)];
        [_btnPrev setTitle: @"Previous" forState: UIControlStateNormal];
        // [_btnPrev setBackgroundColor:[UIColor grayColor]];
        [_btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents: UIControlEventTouchUpInside];
        [_inputAccView addSubview:_btnPrev];
    }
    
   
 
        
    // Do the same for the two buttons left.
    _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnNext setFrame:CGRectMake(150.0f, 0.0f, 80.0f, 40.0f)];
    [_btnNext setTitle:@"Next" forState:UIControlStateNormal];
   // [_btnNext setBackgroundColor:[UIColor grayColor]];
    [_btnNext addTarget:self action:@selector(gotonexttextfield) forControlEvents:UIControlEventTouchUpInside];
    [_inputAccView addSubview:_btnNext];

    
   
        _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnDone setFrame:CGRectMake(250.0, 0.0f, 80.0f, 40.0f)];
        [_btnDone setTitle:@"Done" forState:UIControlStateNormal];
        [_btnDone addTarget:self action:@selector(signUpBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccView addSubview:_btnDone];

 
    
    // Now that our buttons are ready we just have to add them to our view.
    [_inputAccView addSubview:_btnNext];
   
}

- (void) gotoPrevTextfield{
    // If the active textfield is the first one, can't go to any previous
    // field so just return.
  
    if (_activeField  == _txtlname) {
        [_txtfname becomeFirstResponder];
    }
    else if( _activeField == _txtcontact){
            [_txtlname becomeFirstResponder];
        }
    else if (_activeField == _txtemail){
            [_txtcontact becomeFirstResponder];
        }
    else if (_activeField == _txtpass){
            [_txtemail becomeFirstResponder];
        }
    else if (_activeField ==_txtconfpass){
        
            [_txtpass becomeFirstResponder];
        }
}

- (void) gotonexttextfield {
    if (_activeField == _txtfname) {
        [_txtlname becomeFirstResponder];
     
    } else if (_activeField == _txtlname) {
        [_txtcontact becomeFirstResponder];
 
    } else if( _activeField == _txtcontact){
        [_txtemail becomeFirstResponder];
    
    }else if (_activeField == _txtemail){
        [_txtpass becomeFirstResponder];
      
    }else if (_activeField == _txtpass){
        [_txtconfpass becomeFirstResponder];
      
    }else if (_activeField ==_txtconfpass){
       
        [_txtconfpass becomeFirstResponder];
        [self signUpBtnPressed];
    }
   
}




@end
