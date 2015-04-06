//
//  IRRoomSelectViewController.m
//  IRAutomation
//
//  Created by bharat jain on 3/9/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRRoomSelectViewController.h"
#import "AppDelegate.h"

@interface IRRoomSelectViewController ()

@end

@implementation IRRoomSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WING";
    // Do any additional setup after loading the view.
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initialize{
    
    // Array of Images
    imgList = @[@"aircondition_icn-Small", @"aircondition_icn-Small", @"aircondition_icn-Small"];
    
    //Array of TextField
    nameList = @[@"Room 1 Left Wing",@"Room 1 Right Wing",@"Room 2"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"IRRoom";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:30];
    
    lblTitle.text = [nameList objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageNamed:[imgList objectAtIndex:indexPath.row]];
    //just removes the extra lines
    tableView.tableFooterView = [UIView new];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"IRAcViewController" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"IRAcViewController" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"IRAcViewController" sender:self];
            break;
            
        default:
            break;
    }
    
}

@end
