//
//  IRSecondViewController.h
//  IRAutomation
//
//  Created by bharat jain on 2/27/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constant.h"

@interface IRSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

{
    
    NSArray *imgList;
    NSArray *nameList;
    
}


- (void)initialize;

- (IBAction)OpenClose:(id)sender;

- (IBAction)backToAppliances:(id)sender;
@end
