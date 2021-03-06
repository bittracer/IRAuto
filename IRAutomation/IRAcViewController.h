//
//  IRAcViewController.h
//  IRAutomation
//
//  Created by bharat jain on 3/3/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACRemote.h"
#import "ACRemoteModelService.h"
#import <IRKit/IRPeripheral.h>
#import <IRKit+Internal.h>
#import "RS_SliderView.h"
#import "IRAdminViewConroller.h"
#import <Parse/Parse.h>

@interface IRAcViewController : UIViewController <UIAlertViewDelegate> {
    
    UIAlertView *alert;
    UIAlertView *alertSignal;
    PFQuery *query ;
}



- (IBAction)openClose:(id)sender;
- (IBAction)AcOnOff:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *swinh;
@property (weak, nonatomic) IBOutlet UILabel *temprature;
@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (nonatomic , weak) PFObject *otherObject;
@property (nonatomic,retain) NSString *nameOfAc;
@property (nonatomic) PFObject *dataPart;
@property (nonatomic) NSMutableArray *trial;

//IRkit
- (NSString *)stringOfURLEncodedDictionary:(NSDictionary *)params ;
@property (nonatomic) IRPeripheral *Peripheral;

-(void) initializeForSlider;
-(void) checkIfAlreadyCollaborated;

- (void)FetchData:(NSInteger)tag;
//-(BOOL) storeValueAtCloud:(NSArray *)data;

//Parse


@end

NSUserDefaults *defaults;
ACRemote *ac;
NSArray *signalNames;
NSArray *db;
NSMutableArray *remoteArray;
NSMutableArray *data;
NSArray *imagesname;
RS_SliderView *horSlider;
NSString *lastValue;

