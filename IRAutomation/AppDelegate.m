//
//  AppDelegate.m
//  IRAutomation
//
//  Created by bharat jain on 2/18/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "AppDelegate.h"
#import <UIViewController+MMDrawerController.h>
#import "IRRootView.h"
#import "IRMenu.h"
#import <MMDrawerController/MMDrawerController.h>
#import <IRKit/IRKit.h>
#import <Parse/Parse.h>
#import <IRKit/IRHTTPClient.h>
#import "IRHomePageViewController.h"
#import <IRHTTPClient.h>
#import <IRKeys.h>
#import <IRGuideWifiViewController.h>


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize controller;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //IrKit API Key Code
    [IRKit startWithAPIKey:@"7692385BA559429DAD6992330C9B39E7"];
    

    //Parse cloud code below
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"ZDhv4vindt8C2Q4W4JuYXYuu5ZcoSADKvQ6SpHsM"
                  clientKey:@"hOkA4OBEBLweBlsDsRMyAEl3RKNzdkZxaroKZt1V"];
    
    
    
     return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
   }

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
   }

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
   }

- (void)applicationDidBecomeActive:(UIApplication *)application {

    
   }

- (void)applicationWillTerminate:(UIApplication *)application {
    
   }


-(void)userLogin:(NSString *)root{
    
   
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"IRHomePage"
                                                             bundle: nil];
    
    UINavigationController *rootView=(UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier: root];
    IRMenu *sideMenu=(IRMenu *)[mainStoryboard instantiateViewControllerWithIdentifier: @"IRMenu"];
 
    if (!self.controller) {
        self.controller = [[MMDrawerController alloc]initWithCenterViewController:rootView rightDrawerViewController:sideMenu];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [controller setMaximumRightDrawerWidth:screenRect.size.width -(screenRect.size.width/3) ];
    //[controller setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [controller setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    [navController presentViewController:controller animated:YES completion:^{
       [navController popToRootViewControllerAnimated:NO];
    }];
    
//    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
//    self.window.rootViewController=controller;
//    [self.window  makeKeyAndVisible];
}

@end

