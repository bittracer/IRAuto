//
//  IRAcViewController.h
//  IRAutomation
//
//  Created by bharat jain on 3/3/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRKit/IRPeripheral.h>
#import <IRKit+Internal.h>
#import "RS_SliderView.h"

@interface IRAcViewController : UIViewController <UIAlertViewDelegate> {
    
    UIAlertView *alert;
    UIAlertView *alertSignal;
    
}
@property (weak, nonatomic) IBOutlet UIView *panelView;


- (IBAction)openClose:(id)sender;
- (IBAction)AcOnOff:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *temprature;


//IRkit
- (NSString *)stringOfURLEncodedDictionary:(NSDictionary *)params ;
@property (nonatomic) IRPeripheral *Peripheral;

-(void) initialize;
-(void) retriveSignals;
-(void) checkIfAlreadyCollaborated;

- (void)FetchData:(NSInteger)tag;
//-(BOOL) storeValueAtCloud:(NSArray *)data;

//Parse


@end

NSUserDefaults *defaults;
NSArray *signalNames;
RS_SliderView *horSlider;