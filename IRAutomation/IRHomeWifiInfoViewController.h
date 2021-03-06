//
//  IRHomeWifiInfoViewController.h
//  IRAutomation
//
//  Created by bharat jain on 3/23/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRKeys.h>
#import <IRWifiEditViewController.h>
#import <IRGuideWifiViewController.h>
#import <IRSearcher.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLLocationManager.h>

@interface IRHomeWifiInfoViewController : UIViewController <
            IRGuideWifiViewControllerDelegate,
            UIAlertViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate>
{
    UIPickerView *myPickerView;
    NSArray *pickerArray;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *ssid;
@property (weak, nonatomic) IBOutlet UITextField *security;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *activeField;

- (IBAction)submitBtnPressed;
@property (nonatomic) IRKeys *keys;

- (void)fetchCurrentLocation;
@end

NSUserDefaults *defaults;
