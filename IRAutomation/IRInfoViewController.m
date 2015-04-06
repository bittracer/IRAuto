//
//  IRFirstViewController.m
//  IRAutomation
//
//  Created by bharat jain on 2/27/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRInfoViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "AppDelegate.h"

@interface IRInfoViewController ()

@end

@implementation IRInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [appDel.controller setCenterViewController:rootView withCloseAnimation:YES completion:^(BOOL finished) {
        
    }];

}
@end
