//
//  IRSecondViewController.m
//  IRAutomation
//
//  Created by bharat jain on 2/27/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRSettingViewController.h"
#import "IRDatabase.h"
#import "IRAcViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "AppDelegate.h"


@interface IRSettingViewController ()


@end

@implementation IRSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    defaults=[NSUserDefaults standardUserDefaults];
    //fetch previous state of switch
    lastValue= [defaults objectForKey:@"farenheit"];
    notification_Last_state=[defaults objectForKey:@"notification"];
    [self initialize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backToAppliances:(id)sender {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *rootView;
    rootView=(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"IRRootView"];
    [appDel.controller setCenterViewController:rootView withCloseAnimation:YES  completion:^(BOOL finished) {
        
    }];
}


-(void) initialize{
    
    // Array of Images
    imgList = @[@"notification_icn",@"celcius_icn"];
    
    //Array of TextField
    nameList = @[@"notification",@"Farenheit/Celcius"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = SETTING_CELL_IDENTYFIER;
   
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:SETTING_CELL];
    
    lblTitle.text = [nameList objectAtIndex:indexPath.row];
  
    
    cell.imageView.image=[UIImage imageNamed:[imgList objectAtIndex:indexPath.row]];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView=(UISwitch *)[cell.contentView viewWithTag:SETTING_SWITCH];
    cell.accessoryView = switchView;
    
    
    if(indexPath.row==TEMP_SWITCH_PRESSED)//1
    {
        if( [lastValue isEqualToString:@"swtchon"] )
        {
            [switchView setOn:YES animated:NO];
        }
        else
        {
            [switchView setOn:NO animated:NO];
        }
    }
    else if(indexPath.row==NOTIFIACTION_SWITCH_PRESSED)//0
    {
        if( [notification_Last_state isEqualToString:@"swtchon"] )
        {
            [switchView setOn:YES animated:NO];
        }
        else
        {
            [switchView setOn:NO animated:NO];
        }
    }

    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    //just removes the extra lines
    tableView.tableFooterView = [UIView new];
    
    return cell;
}


- (void) switchChanged:(id)sender {
    
    //To identifie at which line switch is toggled in tableview
    
    UISwitch *switchInCell = (UISwitch *)sender;
    UITableViewCell * cell = (UITableViewCell*) switchInCell.superview.superview;
    NSIndexPath * indexpath = [_mytabelview indexPathForCell:cell];
    
    //for notificaon
    if (indexpath.row==0) {
        
        //code for notification
        if (switchInCell.on) {
            
            [defaults setObject:[NSString stringWithFormat:@"swtchon"] forKey:@"notification"];
            AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDel.manager startUpdatingLocation];

            // [self initializeLocationManager];
        }
        else{
            [defaults setObject:[NSString stringWithFormat:@"swtchoff"] forKey:@"notification"];
            AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDel.manager stopUpdatingLocation];
        }
        
        [defaults synchronize];
        return;
    }
    else
    {
        if (switchInCell.on) {
            
            [defaults setObject:[NSString stringWithFormat:@"swtchon"] forKey:@"farenheit"];
        }
        else
        {
            [defaults setObject:[NSString stringWithFormat:@"swtchof"]  forKey:@"farenheit"];
        }
        
        [defaults synchronize];
        
    }
    
}


- (IBAction)OpenClose:(id)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
}


@end
