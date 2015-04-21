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

@property (weak, nonatomic) IBOutlet UITableView *mytabelview;


//@property (nonatomic,strong) CLLocationManager *locationmanager;

- (void)initialize;
//- (void)initializeLocationManager;



- (IBAction)OpenClose:(id)sender;


- (IBAction)backToAppliances:(id)sender;
- (void) switchChanged:(id)sender;
@end

NSUserDefaults *defaults;
NSString *lastValue;
NSString *notification_Last_state;
