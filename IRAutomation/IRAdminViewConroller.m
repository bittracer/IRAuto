//
//  IRAdminConrollerViewController.m
//  IRAutomation
//
//  Created by bharat jain on 4/7/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRAdminViewConroller.h"
#import <Parse/Parse.h>
#import "IRAcViewController.h"

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
    image =@"aircondition_icn-Small";
    self.navigationItem.hidesBackButton=YES;
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
        
        // This will create the class on parse
        object = [PFObject objectWithClassName:@"AcList"];
<<<<<<< HEAD
                
=======
        
>>>>>>> origin/master
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){

                [self performSegueWithIdentifier:@"AcSetup" sender:self];

            }
            else{
                
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"Failed" message:@"please Re-enter" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
                
            }
        }];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listOfAc count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"fromLoginCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:31];
    
    lblTitle.text = [_listOfAc  objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageNamed:image];
    //just removes the extra lines
    tableView.tableFooterView = [UIView new];
   // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
        IRAcViewController *vc= (IRAcViewController *)[segue destinationViewController];
       vc.nameOfAc=_UITextField.text;
        vc.dataPart=object;
    
}


@end
