 //
//  ViewController.m
//  IRAutomation
//
//  Created by bharat jain on 2/18/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRLoginViewController.h"
#import "NSString+FormValidation.h"
#import "Constant.h"
#import "IRDBManager.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <IRWifiEditViewController.h>
#import <IRKit/IRKit.h>
#import <IRKeys.h>
#import <Log.h>
#import <IRNewPeripheralViewController.h>
#import "IRHomeWifiInfoViewController.h"
#import <IRHTTPClient.h>
#import <UIKit/UIResponder.h>

@interface IRLoginViewController  ()

@property (nonatomic) id becomeActiveObserver;
@end

@implementation IRLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
      [self registerForKeyboardNotifications];
    [self addLeftView];
    
    _becomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidBecomeActiveNotification
                                                                              object: nil
                                                                               queue: [NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
                                                                              LOG(@"became active");
                                                                              if (!self.stopSearchCalled) {
                                                                                  
                                                                                  [self startSearch];
                                                                              }
                                                                           
                                                                          }];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
 

}


-(void)dismissKeyboard {
    
  [self.view endEditing:YES];
    
}

- (void)registerDeviceIfNeeded {
    if (!_keys.keysAreSet) {
        [IRHTTPClient registerDeviceWithCompletion: ^(NSHTTPURLResponse *res, NSDictionary *keys, NSError *error) {
            if (error) {
                return;
            }
            [_keys setKeys: keys];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    
    if(textField == _userNametxtfield)
    {
         [_passwordtxtfield becomeFirstResponder];
        // [self moveKeyboardUp];
    }
    else if (textField == _passwordtxtfield)
    {
        [_passwordtxtfield resignFirstResponder];
        [self signinBtnPressed:nil];
        //[self moveKeyboardDown];
    }
    return YES; // We do not want UITextField to insert line-breaks.
}



- (IBAction)signinBtnPressed:(id)sender {
   // BOOL data;
    
        if(!([_userNametxtfield.text isValidString] || [_passwordtxtfield.text  isValidPassword])){
        
            [[[UIAlertView alloc] initWithTitle:nil message:ALL_TEXTFIELD_EMPTY delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
        else if(![_userNametxtfield.text isValidEmail])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:FNAME_ERROR delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
          
        }
        else if(![_passwordtxtfield.text  isValidPassword])
             {
                 [[[UIAlertView alloc] initWithTitle:nil message:LNAME_ERROR delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
             }
        else{
           
            _indicator.hidden = NO;
            [_indicator startAnimating];
            
                [self performSelector:@selector(searchOnParseCloud) withObject:nil afterDelay:0.6];
            
        }
}


- (void) searchOnParseCloud{
    
    [PFUser logInWithUsernameInBackground:_userNametxtfield.text password:_passwordtxtfield.text
                                    block:^(PFUser *user, NSError *error) {
                                        [_indicator stopAnimating];
                if (user) {
                // Do stuff after successful login.
                    
                    if ( ([IRKit sharedInstance].countOfReadyPeripherals == 0)) {
                        
                        [self registerDeviceIfNeeded];
                        
                        [self performSegueWithIdentifier:@"IRHomeWifiInfoViewController" sender:self];
                        
                    }
                    else{
                        
                    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDel userLogin:@"IRRootView"];
                        
                    }
                
                }
                else {
                 // The login failed. Check error to see why.
                    NSString *errorString = [error userInfo][@"error"];
                 [[[UIAlertView alloc] initWithTitle:nil message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                    }
            }];
    

}

- (void) invalidLeftview :(UITextField *)txtfield :(NSString *)image
{

    imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imgview setImage:[UIImage imageNamed:image]];
    [imgview setContentMode:UIViewContentModeScaleAspectFit];
    txtfield.leftView=imgview;
    txtfield.leftViewMode=UITextFieldViewModeAlways;
    
}



- (void)addLeftView {
    

    imgs=[NSArray arrayWithObjects:@"user_icn-Small",@"pass_icn-Small", nil];
     textfield=[NSArray arrayWithObjects:_userNametxtfield,_passwordtxtfield,nil];

    
    for(int i=0; i<2; i++)
    {
    imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35,43)];
    [imgview setImage:[UIImage imageNamed:[imgs objectAtIndex:i]]];
    [imgview setContentMode:UIViewContentModeScaleAspectFit];

    UITextField *u1=[textfield objectAtIndex:i];
    u1.leftView=imgview;
    u1.layer.borderWidth=1;
    u1.layer.borderColor=[[UIColor colorWithRed:209/255.0 green:201/255.0 blue:192/255.0 alpha:1.0f] CGColor];
    u1.leftViewMode=UITextFieldViewModeAlways;
        
    }
  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    IRHomeWifiInfoViewController *vc= (IRHomeWifiInfoViewController *)[segue destinationViewController];
    vc.keys=_keys;
    
}



#pragma mark - IRSearcher related

// start searching for the first 30 seconds,
// if no new IRKit device found, stop then
- (void)startSearch {
    LOG_CURRENT_METHOD;
    _stopSearchCalled = false;
    
    [IRSearcher sharedInstance].delegate = self;
    [[IRSearcher sharedInstance] startSearching];
}

- (void)stopSearch {
    LOG_CURRENT_METHOD;
    _stopSearchCalled = YES;
    
    [[IRSearcher sharedInstance] stop];
}



#pragma mark - IRSearcherDelegate

- (void)searcher:(IRSearcher *)searcher didResolveService:(NSNetService *)service {
    
    LOG(@"service: %@", service);
    IRPeripherals *peripherals = [IRKit sharedInstance].peripherals;
    
    NSString *name  = [service.hostName componentsSeparatedByString: @"."][ 0 ];
    IRPeripheral *p = [peripherals peripheralWithName: name];
    if (!p) {
        p = [peripherals registerPeripheralWithName: name];
        [peripherals save];
    }
    if (!p.deviceid) {
      
        [p getKeyWithCompletion:^{
            [peripherals save];
            self.foundPeripheral = p;      // temporary retain, til alert dismisses
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: IRLocalizedString(@"New IRKit found!", @"alert title when new IRKit is found")
                                                            message: @""
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: @"OK", nil];
            [alert show];
        }];
    }
}

- (void)searcherWillStartSearching:(IRSearcher *)searcher {
    LOG_CURRENT_METHOD;
}

- (void)searcherDidTimeout:(IRSearcher *)searcher {
    LOG_CURRENT_METHOD;
}


//IRSercher



- (IBAction)demo:(id)sender {
}
@end


