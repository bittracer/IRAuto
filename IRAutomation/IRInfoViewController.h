//
//  IRFirstViewController.h
//  IRAutomation
//
//  Created by bharat jain on 2/27/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRInfoViewController : UIViewController
- (IBAction)OpenClose:(id)sender;

- (IBAction)backToAppliances:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *openUrl;
- (IBAction)openURL:(id)sender;

@end
