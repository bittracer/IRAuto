//
//  IRMenu.m
//  IRAutomation
//
//  Created by bharat jain on 2/26/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRMenu.h"
#import "AppDelegate.h"
#import "IRHomePageViewController.h"

@interface IRMenu ()

@end

@implementation IRMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuList =[NSArray arrayWithObjects:@"info@info.com",@"Setting",@"Appliances",@"Logout",nil];
    menuImage=[NSArray arrayWithObjects:@"aircondition_icn-Small.png",@"aircondition_icn-Small.png",@"aircondition_icn-Small.png",@"logout_btn-Small.png", nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"irMenuCellidentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:20];
    
    lblTitle.text = [menuList objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageNamed:[menuImage objectAtIndex:indexPath.row]];
    //just removes the extra lines
    tableView.tableFooterView = [UIView new];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // you can use "indexPath" to know what cell has been selected as the following
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *rootView;
    if(indexPath.row==0){
        rootView=(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"IRInfoViewController"];
    }
    else if (indexPath.row==1){
       rootView=(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"IRSettingViewController"];
    }
    else if (indexPath.row==2){
         rootView=(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"IRRootView"];
    }
    else if (indexPath.row==3){
       rootView=(UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"IRRootView"];
        
        [appDel.controller dismissViewControllerAnimated:YES completion:^{
            [appDel.controller setCenterViewController:rootView withCloseAnimation:YES completion:^(BOOL finished) {
                
            }];
        }];
    }
    if(indexPath.row!=3){
    [appDel.controller setCenterViewController:rootView withCloseAnimation:YES completion:^(BOOL finished) {
        
    }];}
    
}
@end
