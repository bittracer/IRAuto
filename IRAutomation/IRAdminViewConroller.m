//
//  IRAdminConrollerViewController.m
//  IRAutomation
//
//  Created by bharat jain on 4/7/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRAdminViewConroller.h"

@interface IRAdminViewConroller ()


@end

@implementation IRAdminViewConroller

UITextField *_UITextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAppliance)];
    self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNewAppliance{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Appliance Name" message:@"Enter the name of the appliance you want to calibrate" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    
    _UITextField  = [alert textFieldAtIndex:0];
    _UITextField.placeholder = @"Appliance Name";
    _UITextField.keyboardType = UIKeyboardTypeEmailAddress;
    [alert show];
    
    
    
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)//OK button
    {
        NSLog(@"%@",_UITextField.text);
        [self performSegueWithIdentifier:@"AcSetup" sender:self];
    }
}

@end
