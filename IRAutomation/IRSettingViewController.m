//
//  IRSecondViewController.m
//  IRAutomation
//
//  Created by bharat jain on 2/27/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRSettingViewController.h"
#import "IRAcViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "AppDelegate.h"


@interface IRSettingViewController ()

@end

@implementation IRSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OpenClose:(id)sender {
    
[self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
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
    
    UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:SETTING_SWITCH];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    

    
    //just removes the extra lines
    tableView.tableFooterView = [UIView new];
    
    return cell;
}


- (void) switchChanged:(id)sender {
    
    //to check at which line switch is toggled
    
    UISwitch *switchInCell = (UISwitch *)sender;
    UITableViewCell * cell = (UITableViewCell*) switchInCell.superview;
    NSIndexPath * indexpath = [_mytabelview indexPathForCell:cell];
    
    if (indexpath.row==0) {
        
        //code for notification
        
        return;
    }
    else
    {
        if (switchInCell.on) {
            
            switchInCell.onImage=[UIImage imageNamed:@"back_btn-Small"];
        
            [defaults setObject:[NSString stringWithFormat:@"swtchon"] forKey:@"farenheit"];
        }
        else
        {
            [defaults setObject:[NSString stringWithFormat:@"swtchof"]  forKey:@"farenheit"];
        }
        
    }
    
}


@end
