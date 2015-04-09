//
//  IRRoomSelectViewController.m
//  IRAutomation
//
//  Created by bharat jain on 3/9/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRRoomSelectViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "IRAcViewController.h"

@interface IRRoomSelectViewController ()

@end


@implementation IRRoomSelectViewController


- (void) viewWillAppear:(BOOL)animated{
    
    [self initialize];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WING";
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initialize{
    
    // Array of Images
    image =@"aircondition_icn-Small";

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_nameList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"IRRoom";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:30];
    
    lblTitle.text = [_nameList  objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageNamed:image];
    //just removes the extra lines
    tableView.tableFooterView = [UIView new];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    nameOfAc=_nameList[indexPath.row];
    
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    IRAcViewController *Ac=(IRAcViewController *)[segue destinationViewController];
    Ac.nameOfAc=nameOfAc;
    
}
@end
