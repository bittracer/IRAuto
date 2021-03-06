//
//  IRHomeWifiInfoViewController.m
//  IRAutomation
//
//  Created by bharat jain on 3/23/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRHomeWifiInfoViewController.h"
#import <IRKeys.h>
#import <IRHelper.h>
#import <IRGuideWifiViewController.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "constant.h"
#import "IRAdminViewConroller.h"

static NSString *ssidCache = nil;
CLLocation *currentLocation;


@interface IRHomeWifiInfoViewController ()

@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation IRHomeWifiInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchCurrentLocation];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    self.navigationItem.hidesBackButton = YES;
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self initpickerView];
    }

- (void)fetchCurrentLocation
{
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate=self;
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    
            [_locationManager requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];

    }
    _locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [_locationManager startUpdatingLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of ayooony resources that can be recreated.
}

- (IBAction)submitBtnPressed{
    
    if (![IRKeys isPassword:_password.text validForSecurityType: _keys.security]) {
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Invalid Password", @"alert title in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [_password becomeFirstResponder];
    }
    if ([_ssid.text rangeOfString: @","].location != NSNotFound) {
        // if "," exists in ssid
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"SSID and Password can't include \",\" please change your Wi-Fi settings", @"alert title in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [_ssid becomeFirstResponder];
       
    }
    if ([_ssid.text rangeOfString: @"IRKit" options: NSCaseInsensitiveSearch|NSAnchoredSearch].location != NSNotFound) {
        // I bet your home wi-fi network name doesn't start with "IRKit"
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Input your HOME Wi-Fi information", @"alert title to input HOME Wi-Fi information in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [_ssid becomeFirstResponder];
    }
    if ([_password.text rangeOfString: @","].location != NSNotFound) {
        // if "," exists in password
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"SSID and Password can't include \",\" please change your Wi-Fi settings", @"alert title in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [_password becomeFirstResponder];
    }
    
    ssidCache = [_ssid copy];
    
    _keys.ssid     = _ssid.text;
    _keys.password = _password.text;
    NSLog(@"SSID :%@",_ssid.text);
    NSLog(@"password :%@",_password.text);
    
    if(_ssid.text.length > 0 && _password.text.length > 0){
        
        IRGuideWifiViewController *c = [[IRGuideWifiViewController alloc] initWithNibName: @"IRGuideWifiViewController"
                                                                                   bundle: [IRHelper resources]];
        c.delegate = self;
        c.keys     = _keys;
        [self.navigationController pushViewController: c animated: YES];
    }else{
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"FILL IN DETAILS" message:@"Fields cannot be left blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil ];
        [alertView show];
        if(_ssid.text.length == 0){
            [_ssid becomeFirstResponder];}
        else if (_password.text.lastPathComponent ==0){
            [_password becomeFirstResponder];
        }
        
    }

}


#pragma mark - IRGuideWifiViewControllerDelegate

- (void)guideWifiViewController:(IRGuideWifiViewController *)viewController
              didFinishWithInfo:(NSDictionary *)info {
    
    
    [[PFUser currentUser]fetch];
    NSString *str=[NSString stringWithFormat:@"%@",
                   [[PFUser currentUser] objectForKey:@"username"]];

    if( [str isEqualToString:ADMIN_LOGIN_ID] ){
        
        IRAdminViewConroller *admin= [[IRAdminViewConroller alloc] init];
        [self.navigationController pushViewController:admin animated:YES];
        
    }
    else
    {
        
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDel userLogin:@"IRRootView"];
        
    }
}


#pragma mark - UITextFieldDelegate




- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _ssid) {
        [_security becomeFirstResponder];
        //  [self moveKeyboardUp];
    } else if (theTextField == _security) {
        [_password becomeFirstResponder];
        //[self moveKeyboardUp];
    } else if( theTextField == _password){
        [_password becomeFirstResponder];
        //[self moveKeyboardUp];
        [self submitBtnPressed];
    }
    return YES;
}

-(void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
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



# pragma mark - Initialize PickerView

-(void)initpickerView{
    pickerArray = [[NSArray alloc]initWithObjects:@"NONE",
                   @"WPA2",@"WEP", nil];
   
    _security.delegate = self;
   
    [_security setPlaceholder:@"NONE/WEP/WPA2"];
    myPickerView = [[UIPickerView alloc]init];
    myPickerView.dataSource = self;
    myPickerView.delegate = self;
    //myPickerView.showsSelectionIndicator = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                   target:self action:@selector(dismissKeyboard)];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height-
                                     myPickerView.frame.size.height-50, 320, 50)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             doneButton, nil];
    [toolBar setItems:toolbarItems];
    _security.inputView = myPickerView;
    _security.inputAccessoryView = toolBar;
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [self fetchCurrentLocation];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation=[locations lastObject];
    NSNumber *lat = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
    NSDictionary *userLocation=@{@"lat":lat,@"long":lon};

    
    [defaults setObject:userLocation forKey:@"location"];
    [defaults synchronize];
    NSLog(@"loc %@",currentLocation);
    [_locationManager stopUpdatingLocation];
}



#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return [pickerArray count];
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component{
    [_security setText:[pickerArray objectAtIndex:row]];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:
(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}

@end
