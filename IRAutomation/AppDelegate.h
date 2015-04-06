//
//  AppDelegate.h
//  IRAutomation
//
//  Created by bharat jain on 2/18/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MMDrawerController/MMDrawerController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong)MMDrawerController *controller;

-(void)userLogin:(NSString *)root;


@end

