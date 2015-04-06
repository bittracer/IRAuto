//
//  ViewController.h
//  IRAutomation
//
//  Created by bharat jain on 2/18/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRWifiEditViewController.h>
#import <IRGuidePowerViewController.h>
#import <IRNewPeripheralViewController.h>
#import <IRSearcher.h>


@interface IRLoginViewController : UIViewController  <UITextFieldDelegate,IRSearcherDelegate>
{
    
    UIImageView *imgview ;
    NSArray *textfield;
    NSArray *imgs;

}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic) BOOL stopSearchCalled;
@property (nonatomic, weak) id<IRWifiEditViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *activeField;
@property (weak, nonatomic) IBOutlet UITextField *userNametxtfield;
@property (nonatomic) IRPeripheral *foundPeripheral;
@property (weak, nonatomic) IBOutlet UITextField *passwordtxtfield;
- (IBAction)demo:(id)sender;

//IRkit

@property (nonatomic) IRKeys *keys;



- (IBAction)signinBtnPressed:(id)sender;
- (void)addLeftView;

- (void) invalidLeftview :(UITextField *)txtfield :(NSString *)image;
//
//- (void)moveKeyboardUp;
//- (void) moveKeyboardDown;
- (void) searchOnParseCloud;
@end


