//
//  IRAdminConrollerViewController.h
//  IRAutomation
//
//  Created by bharat jain on 4/7/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface IRAdminViewConroller : UIViewController <UIAlertViewDelegate>
{
    
    PFObject *object ;
}

-(void) addNewAppliance;


@end

