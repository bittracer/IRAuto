//
//  IRHomePageViewController.m
//  IRAutomation
//
//  Created by bharat jain on 2/24/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRHomePageViewController.h"
#import "IRLoginViewController.h"
#import "constant.h"
#import <IRHelper.h>
#import <IRHTTPClient.h>
#import <Log.h>
#import <IRKit/IRKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"


@interface IRHomePageViewController ()

@end

@implementation IRHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    _keys =[[IRKeys alloc]init];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"IRLogin"]){
    IRLoginViewController *vc= (IRLoginViewController *)[segue destinationViewController];
    vc.keys=_keys;
    }
    
}


@end
