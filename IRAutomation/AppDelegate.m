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
#import "IRDatabase.h"
#import "ACRemoteModelService.h"


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
    
    
    [IRDatabase setDatabasePath];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        _manager =[[CLLocationManager alloc]init];
        _manager.delegate=self;
        _manager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        _manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [_manager startMonitoringSignificantLocationChanges];

    }
          return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
   }

- (void)applicationDidEnterBackground:(UIApplication *)application {
    defaults=[NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"notification"] isEqualToString:@"swtchon"])
    {
        [_manager startUpdatingLocation];}
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

    _manager =[[CLLocationManager alloc]init];
    _manager.delegate=self;
    _manager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
        NSArray *tempArray = [ACRemoteModelService getACRemotes];
        ACRemote *ac=[tempArray objectAtIndex:0];
        
        if ([[ac valueForKey:@"acstate"] isEqualToString:@"Acon"]) {
            
            CLLocation *currentLocation=[locations lastObject];
            
            NSDictionary *userLoc=[[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
            
            location=[defaults objectForKey:@"location"];
            CLLocationDegrees lat=[[userLoc objectForKey:@"lat"] doubleValue];
            CLLocationDegrees lon=[[userLoc objectForKey:@"long"] doubleValue];
            location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            
            CLLocationDistance distance = [location distanceFromLocation:currentLocation];
            if (distance >= 1) {
                
                UILocalNotification *localNotification=[[UILocalNotification alloc] init];
                localNotification.alertBody = @"you forgot to TURN OFF your AC";
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.fireDate = [NSDate date];
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                [_manager stopUpdatingLocation];
                [_manager stopMonitoringSignificantLocationChanges];}
        
        }
}


@end

