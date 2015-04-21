//
//  AppDelegate.h
//  IRAutomation
//
//  Created by bharat jain on 2/18/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MMDrawerController/MMDrawerController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong)MMDrawerController *controller;

@property (nonatomic, strong) CLLocationManager *manager;


-(void)userLogin:(NSString *)root;


@end

CLLocation *location;
NSUserDefaults *defaults;