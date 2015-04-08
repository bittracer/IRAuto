


//
//  IRAcViewController.m
//  IRAutomation
//
//  Created by bharat jain on 3/3/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRAcViewController.h"
#import "constant.h"
#import "RS_SliderView.h"
#import <UIViewController+MMDrawerController.h>
#import <IRKit/IRKit.h>
#import <IRPeripheral.h>
#import <Parse/Parse.h>
#import <IRKeys.h>
#import <Log.h>
#import <IRHTTPClient.h>
#import "RS_SliderView.h"

NSURL *url ;
NSString *aStr;
NSString *a=@"true";
static int signalscount=0;
PFQuery *query;
PFObject *dataPart;
NSString *First=@"@\"{\"format\":\"raw\",\"freq\":38,\"data\":";
NSString *Last=@"}\"";
NSString *Full=@"";
NSString *CurrentStatus;



@interface IRAcViewController () <RSliderViewDelegate>

@property (nonatomic) IRHTTPClient *waiter;
@property (nonatomic, strong) NSURLConnection   *connection;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData     *data;
@property (nonatomic, copy) void (^handler)(NSHTTPURLResponse *response, id object, NSError *error);

@end

@implementation IRAcViewController

int temprature;

- (void)viewDidLoad {
    [super viewDidLoad];
    //_Peripheral=[[IRKit sharedInstance].peripherals objectAtIndex:0];
    _panelView.layer.borderColor =AC_PANEL_BORDER_COLOR;
    
     defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"false"] forKey:@"onoff"];
    [defaults setObject:[NSString stringWithFormat:@"swtchof"] forKey:@"farenheit"];

    [defaults synchronize];
    

     signalNames=@[@"Ac/off",@"Ac/on",@"Auto",@"Cool",@"Dry",@"Fan",@"Heat",@"Timer",@"Night",@"Turbo",@"SwingH",@"SwingV",@"Temp16",@"Temp17",@"Temp18",@"Temp19",@"Temp20",@"Temp21",@"Temp22",@"Temp23",@"Temp24",@"Temp25",@"Temp26",@"Temp27",@"Temp28",@"Temp29",@"Temp30"];
    
   // Init UISlider
    [self initialize];

}

-(void)viewDidAppear:(BOOL)animated{
  
    [[PFUser currentUser]fetch];
    NSString *str=[NSString stringWithFormat:@"%@",
                   [[PFUser currentUser] objectForKey:@"username"]];
    
    if([str isEqualToString:ADMIN_LOGIN_ID]){
        
        [self checkIfAlreadyCollaborated];
    }
    
}


#pragma mark - Initialize Slider

-(void) initialize{
    
    horSlider = [[RS_SliderView alloc] initWithFrame:CGRectMake(10, 340, 300, 100) andOrientation:Horizontal];
    horSlider.delegate = self;
    [horSlider setColorsForBackground:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
                           foreground:[UIColor colorWithRed:0.0 green:132.0/255.0 blue:210.0/255.0 alpha:1.0]
                               handle:nil
                               border:[UIColor colorWithRed:0.0 green:132.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    [self.view addSubview:horSlider];
    
    UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(10,340,300,100)];
    dot.image=[UIImage imageNamed:@"swipe.png"];
    dot.backgroundColor =[UIColor clearColor];
    [self.view addSubview:dot];
    
    
    UIButton *decreaseTemp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [decreaseTemp addTarget:self
                     action:@selector(decreaseTemp)
           forControlEvents:UIControlEventTouchUpInside];
    [decreaseTemp setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
    decreaseTemp.frame = CGRectMake(20,450,40,40);
    [self.view addSubview:decreaseTemp];
    
    UIButton *increaseTemp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [increaseTemp addTarget:self
                     action:@selector(increaseTemp)
           forControlEvents:UIControlEventTouchUpInside];
    [increaseTemp setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    increaseTemp.frame = CGRectMake(260,460,40,40);
    [self.view addSubview:increaseTemp];
    
}


- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark - Alertview Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==WELCOME_IF_FIRST_TIME)
    {
        //Init Signals
        [self initializeConnection];
       
        return;
    }
    else if (alertView.tag==CALIBRATE_SIGNALS)
    {
        return ;
        
    }
    else if (alertView.tag==SIGNAL_RECEIVED)
    {
        [self initializeConnection];
        return ;
        
    }
    else if (alertView.tag==CALIBRATION_COMPLETE)
    {
        return ;
    }
    else if(alertView.tag==SIGNAL_NOT_STORED){
        
        return;
    }
   
}




// This will always be called before the use of remote so that to check whether there exist any signals in parse
- (void) checkIfAlreadyCollaborated{
    
   
    query = [PFQuery queryWithClassName:@"Signals"];
    [query whereKey:@"state" equalTo:@"Ac/on"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (error) {
            
                alert =[[UIAlertView alloc]initWithTitle:@"Welcome Noob !" message:@"Let's Calibrate the Signals" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                alert.tag=WELCOME_IF_FIRST_TIME;
                [alert show];
                alert = nil;
            
        }
        else {
            
             NSLog(@"%@", object.objectId);
           
        }
    }];
    
}


- (void)initializeConnection{
    
    
if(signalscount < signalNames.count){
       
    alertSignal = nil;
    if (!alertSignal && !alertSignal.isVisible) {
        alert =[[UIAlertView alloc]initWithTitle:@"Calibrate Signal!" message:[NSString stringWithFormat:@"%@",signalNames[signalscount]] delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        alert.tag=CALIBRATE_SIGNALS;
        [alert show];
    }
    
    _waiter = [IRHTTPClient waitForSignalWithCompletion:^(NSHTTPURLResponse *res, IRSignal *signal, NSError *error) {
      
        if (signal) {
            
            dataPart = [PFObject objectWithClassName:@"Signals"];
            dataPart[@"signalData"] = [NSArray arrayWithObjects:signal.data,nil];
            dataPart[@"state"]=[NSString stringWithFormat:@"%@",signalNames[signalscount]];
           
            signalscount++;
            
            [dataPart saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
            
                    [alert dismissWithClickedButtonIndex:-1 animated:YES];
                    alert=nil;
                    alertSignal = [[UIAlertView alloc]initWithTitle:@"Signal Received !" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    alertSignal.tag=SIGNAL_RECEIVED;
                    [alertSignal show];

                } else {
                    
                    signalscount--;
                    
                    alert =[[UIAlertView alloc]initWithTitle:@"Error Calibrating " message:[NSString stringWithFormat:@"Retry %@",signalNames[signalscount]] delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                    alert.tag=SIGNAL_NOT_STORED;
                    [alert show];
                    
                }
            }];
           
        }
     
    }];
    
    }else{
        signalscount=0;
        alert =[[UIAlertView alloc]initWithTitle:@"Well Done !" message:@"Congratulations you are set to go ! Enjoy !" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        alert.tag=CALIBRATION_COMPLETE;
        [alert show];
        alert = nil;

    }
    
}


-(void) retriveSignals{
   
    }

#pragma mark - Remote button presssed

- (IBAction)AcOnOff:(id)sender {

    [self FetchData:[sender tag]];
    
}

- (void)FetchData:(NSInteger)tag
{
    
    

    NSInteger temptag=tag-4;
    PFQuery *query = [PFQuery queryWithClassName:@"Signals"];
    [query selectKeys:@[@"state",@"signalData"]];
    
    CurrentStatus =[defaults objectForKey:@"onoff"];
    
    if(tag==1){
        if ([CurrentStatus isEqualToString:@"false"]) {
            
            NSLog(@"ON");
            [defaults setObject:[NSString stringWithFormat:@"true"] forKey:@"onoff"];
            [defaults synchronize];
            [(UIButton *)([self.view viewWithTag:AC_ON_OFF]) setImage:[UIImage imageNamed:@"onn"] forState:UIControlStateNormal];
            
        }else{
            tag--;
            
            NSLog(@"OFF");
            [defaults setObject:[NSString stringWithFormat:@"false"] forKey:@"onoff"];
            [defaults synchronize];
            [(UIButton *)([self.view viewWithTag:AC_ON_OFF]) setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
        }
    }
    if(temptag>=4 && temptag<=18){
        
        [query whereKey:@"state" equalTo:signalNames[temptag]];
        
    }
    else{
        
        [query whereKey:@"state" equalTo:signalNames[tag]];
    }
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects) {
                
                NSLog(@"objectid %@",object.objectId);
                NSLog(@"%@state",object[@"state"]);
                dataPart= object[@"signalData"];
                
            }
            
            Full=@"";
            Full=[Full stringByAppendingString:[NSString stringWithFormat:@"%@",First]];
            Full=[Full stringByAppendingString:[NSString stringWithFormat:@"%@",dataPart]];
            Full=[Full stringByAppendingString:[NSString stringWithFormat:@"%@",Last]];
            
            
            if(_Peripheral.isReachableViaWifi)
            {
                NSURL *base = [NSURL URLWithString: [NSString stringWithFormat: @"http://%@.local",_Peripheral.hostname]];
                url = [NSURL URLWithString:@"/messages" relativeToURL: base];
                [self requestviawifi];
            }
            
            else
            {
                url = [NSURL URLWithString:@"https://api.getirkit.com/1/messages"];
                [self requestviaInternet];
            }
            
            
        }
    }];
    
}


#pragma mark - sliderValueChanged

-(void)sliderValueChanged:(RS_SliderView *)sender {
    
        temprature = sender.value *14;
        NSLog(@"Temprature: %d",  temprature +16);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\u00b0c", temprature +16]];
        [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-light" size:10.0]
                                      , NSBaselineOffsetAttributeName : @22} range:NSMakeRange(2, 2)];
    
    NSString *swtch= [defaults objectForKey:@"farenheit"];
    
    if ([swtch isEqualToString:@"swtchon"]) {
        
        //convert temprature to farenheit
        
        attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\u00b0f", (int)((((sender.value*14)+16)*1.8)+32)]];
        _temprature.attributedText = attributedString;
        
    }
    else{
        
        attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\u00b0c", temprature +16]];
        _temprature.attributedText = attributedString;
    }
}

#pragma mark - sliderValueChangeEnded

NSMutableAttributedString *attributedString;

-(void)sliderValueChangeEnded:(RS_SliderView *)sender {
    
    
    NSLog(@"Value:%f",sender.value);
    temprature = sender.value *14;
    NSLog(@"Temprature: %d", (temprature+16));

    NSString *swtch= [defaults objectForKey:@"farenheit"];

    
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-light" size:10.0]
                                      , NSBaselineOffsetAttributeName : @22} range:NSMakeRange(2, 2)];
    
    if ([swtch isEqualToString:@"swtchon"]) {
        
        //convert temprature to farenheit
        
        attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\u00b0f", (int)((((sender.value*14)+16)*1.8)+32)]];
        _temprature.attributedText = attributedString;
        
    }
    else{
        
        attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\u00b0c", temprature +16]];
        _temprature.attributedText = attributedString;
    }
    
    [self FetchData:temprature+16];
        
}


#pragma mark - IncreaseTemperature Manually

-(void) increaseTemp{
    
  
        point1.x=point1.x+20.0;
        [horSlider changeStarForegroundViewWithPoint:point1];
        [self sliderValueChangeEnded:horSlider];
    
}


#pragma mark - DecreaseTemperature Manually

-(void) decreaseTemp{
    
          point1.x=point1.x-20.0;
          [horSlider changeStarForegroundViewWithPoint:point1];
          [self sliderValueChangeEnded:horSlider];
    
}



#pragma mark - RequestviaInternet

- (void)requestviaInternet
{
        NSString *deviceid=_Peripheral.deviceid;
    
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        NSMutableDictionary *realParams=[[NSMutableDictionary alloc]init];
        req.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
        req.timeoutInterval = 10;
        [realParams setObject:Full forKey:@"message"];
        [realParams setObject:[IRKit sharedInstance].clientkey forKey:@"clientkey"];
        [realParams setObject:deviceid forKey:@"deviceid"];
    
        NSData *data = [[self stringOfURLEncodedDictionary: realParams] dataUsingEncoding: NSUTF8StringEncoding];

        [req setHTTPMethod:@"POST"];
        [req setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[data length]] forHTTPHeaderField: @"Content-Length"];
        [req setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        [req setHTTPBody:data];
        NSLog(@"Request---%@",req);
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode);
            NSLog(@"%@", (NSHTTPURLResponse *)response);

        }];
    
}

#pragma mark - RequestviaWifi

- (void)requestviawifi
{
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPBody:[Full dataUsingEncoding:NSUTF8StringEncoding]];
    [req setHTTPMethod:@"POST"];
     
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode);
        NSLog(@"%@", (NSHTTPURLResponse *)response);
        
    }];
    
}

//add/retrive data to parse


- (NSString *)stringOfURLEncodedDictionary:(NSDictionary *)params {
    if (!params) {
        return nil;
    }
    NSString *body = [[IRHelper mapObjects: params.allKeys
                                usingBlock:^id (id key, NSUInteger idx) {
                                    if (params[key] == [NSNull null]) {
                                        return [NSString stringWithFormat: @"%@=", key];
                                    }
                                    return [NSString stringWithFormat: @"%@=%@", key, [self URLEscapeString: params[key]]];
                                }] componentsJoinedByString: @"&"];
    return body;
}

- (NSString *)URLEscapeString:(NSString *)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 kCFStringEncodingUTF8);
}

// This will open and close the side drawer

- (IBAction)openClose:(id)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
}



@end
