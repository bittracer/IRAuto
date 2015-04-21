


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

NSString *CurrentStatus;
NSInteger btnindex;



@interface IRAcViewController () <RSliderViewDelegate>

@property (nonatomic) IRHTTPClient *waiter;
@property (nonatomic, strong) NSURLConnection   *connection;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData     *data;
@property (nonatomic, copy) void (^handler)(NSHTTPURLResponse *response, id object, NSError *error);

@end

@implementation IRAcViewController

int temprature;

-(void)loadView1{
    
        remoteArray = [[NSMutableArray alloc]init];
    signalNames=@[@"Acoff",@"Acon",@"auto",@"cool",@"dry",@"fan",@"heat",@"timeroff",@"timeron",@"turboff",@"turboon",@"nightoff",@"nighton",@"SwingH",@"SwingV",@"Temp16",@"Temp17",@"Temp18",@"Temp19",@"Temp20",@"Temp21",@"Temp22",@"Temp23",@"Temp24",@"Temp25",@"Temp26",@"Temp27",@"Temp28",@"Temp29",@"Temp30"];
    
    imagesname=@[@"Acoff",@"Acon",@"auto_active",@"cool_active",@"dry_active",@"fan_active",@"heat_active",@"timeroff",@"timeron",@"turboff",@"turboon",@"nightoff",@"nighton"];
    
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:@"Acoff" forKey:@"acstate"];
        [dictionary setValue:@"" forKey:@"mode"];
        [dictionary setValue:@"timeroff" forKey:@"timer"];
        [dictionary setValue:@"turboff" forKey:@"turbo"];
        [dictionary setValue:@"nightoff" forKey:@"night"];
        [dictionary setValue:@"" forKey:@"slider"];
    
  
    //check if data is already entered in database
    BOOL check=[ACRemoteModelService recordExist];
    if (!check) {
        //if not and dtabase is empty insert defualts to Local DB
         [IRDatabase executeInsert_ReplaceQueryForTable:@"acremote" jsonArray:[NSArray arrayWithObject:dictionary]];
    }
    
    //fetch all values from local database
    NSArray *tempArray = [ACRemoteModelService getACRemotes];
    ac=[tempArray objectAtIndex:0];
    db=[[NSArray alloc]initWithObjects:@"acstate",@"mode",@"turbo",@"timer",@"night",@"slider", nil];
    for(int i=0;i<6;i++){
        [remoteArray addObject:[ac valueForKey:db[i]]];
    }
    
    
    //set all values in UI from Local DB
    for (int i=0; i<remoteArray.count-1; i++) {
        if (![remoteArray[i] isEqualToString:@""] && ![remoteArray[i] isEqualToString:@"<null>"]  ) {
            
            NSUInteger tag=[signalNames indexOfObject:remoteArray[i]];
            
            if ( tag==0 || tag==7 || tag==9 || tag==11) {
                tag++;
            }
            [(UIButton *)([self.view viewWithTag:tag]) setImage:[UIImage imageNamed:[imagesname objectAtIndex:[signalNames indexOfObject:remoteArray[i]]]] forState:UIControlStateNormal];
        }
    }

    //set slider and temprature label from Local DB
    if (![remoteArray[5] isEqual:[NSNull null]]) {
        if (point1.x==0) {
            point1.x=[remoteArray[5] floatValue];
        }
        [horSlider changeStarForegroundViewWithPoint:point1];
        [self sliderValueChanged:horSlider];}
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _Peripheral=[[IRKit sharedInstance].peripherals objectAtIndex:0];
    _panelView.layer.borderColor =AC_PANEL_BORDER_COLOR;
    NSLog(@"------------%@",_nameOfAc);
     defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:[NSString stringWithFormat:@"swtchof"] forKey:@"farenheit"];
    lastValue= [defaults objectForKey:@"farenheit"];
    
    [defaults synchronize];
    query = [PFQuery queryWithClassName:@"AcList"];

   // dataPart = [PFObject objectWithClassName:@"AcList"];
     _dataPart[@"nameOfAc"]=[NSString stringWithFormat:@"%@",_nameOfAc];
    
    
   // Init UISlider
    [self initializeForSlider];
    [self loadView1];

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

-(void) initializeForSlider{
    
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
    
   
    query = [PFQuery queryWithClassName:@"AcList"];
    [query whereKey:@"state" equalTo:@"Acon"];
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
            
           
            _dataPart[[NSString stringWithFormat:@"%@",signalNames[signalscount]]] = [NSArray arrayWithObjects:signal.data,nil];
            
            signalscount++;
            
            [_dataPart saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

#pragma mark - Remote button presssed

- (IBAction)AcOnOff:(id)sender {

    btnindex=[sender tag];
    [self FetchData:btnindex];
    
}

//Fetch signals from Parse

- (void)FetchData:(NSInteger)tag
{
    
    NSInteger temptag=tag-1;
    if(temptag>=15 && temptag<=29){
        
        tag=temptag;
        btnindex=tag;
    }
    else{
        
        NSArray *tempArray = [ACRemoteModelService getACRemotes];
        ac=[tempArray objectAtIndex:0];
   
    switch (tag) {
        case AC:
            if (![[ac valueForKey:@"acstate"] isEqualToString:@"Acoff"]) {
                tag--;
            }
            break;
            
        case TIMER:
            if (![[ac valueForKey:@"timer"] isEqualToString:@"timeroff"]) {
                tag--;
            }
            break;
        case TURBO:
            if (![[ac valueForKey:@"turbo"] isEqualToString:@"turboff"]) {
                tag--;
            }
            break;
            
        case NIGHT:
            if (![[ac valueForKey:@"night"] isEqualToString:@"nightoff"]) {
                tag--;
            }
            break;
        default:
            break;
    }
}
    
        btnindex=tag;
        [query selectKeys:@[@"nameOfAc",[NSString stringWithFormat:@"%@",signalNames[tag]]]];
        [query whereKey:@"nameOfAc" equalTo:_nameOfAc];

    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects) {

                _dataPart= object[[NSString stringWithFormat:@"%@",signalNames[tag]]];
                
            }
            
            
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
    
    
    if ([lastValue isEqualToString:@"swtchon"]) {
        
        //convert temprature to farenheit
        attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\u00b0f", (int)((((sender.value*14)+16)*1.8)+32)]];
        _temprature.attributedText = attributedString;
        
    }
    else{
        
        //Temprature in celcius
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
    
    NSMutableDictionary *payload = @{}.mutableCopy;
    payload[ @"freq" ]   = @38 ;
    payload[ @"data" ]   = _dataPart;
    payload[ @"format" ] =@"raw" ;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *realParams=[[NSMutableDictionary alloc]init];
    req.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    req.timeoutInterval = 100;
    NSData *jsonData      = [NSJSONSerialization dataWithJSONObject: payload options: 0 error: nil];
    NSString *json        = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
    [realParams setObject:json forKey:@"message"];
    [realParams setObject:[IRKit sharedInstance].clientkey forKey:@"clientkey"];
    [realParams setObject:deviceid forKey:@"deviceid"];
    
    NSData *data = [[self stringOfURLEncodedDictionary: realParams] dataUsingEncoding: NSUTF8StringEncoding];
    
    [req setHTTPBody:data];
    [req setHTTPMethod:@"POST"];
    [req setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[data length]] forHTTPHeaderField: @"Content-Length"];
    [req setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    NSLog(@"Request---%@",req);
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode);
        NSLog(@"%@", (NSHTTPURLResponse *)response);
        NSInteger status= (long)((NSHTTPURLResponse *)response).statusCode;
        if(status == 200)
        {
            [self insertDataToLocalDB];
            
        }
        
    }];
    
}
#pragma mark - RequestviaWifi

- (void)requestviawifi
{
    
    NSMutableDictionary *payload = @{}.mutableCopy;
    payload[ @"freq" ]   = @38 ;
    payload[ @"data" ]   = _dataPart;
    payload[ @"format" ] =@"raw" ;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSJSONSerialization dataWithJSONObject: payload options: 0 error: nil];
    [req setHTTPBody:data];
    [req setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode);
        NSLog(@"%@", (NSHTTPURLResponse *)response);
        NSInteger status= (long)((NSHTTPURLResponse *)response).statusCode;
        if(status == 200)
        {
            [self insertDataToLocalDB];
            
        }

        
    }];
    
}

#pragma mark -Data insertion to Local Database

- (void) insertDataToLocalDB
{
    
    NSArray *tempArray = [ACRemoteModelService getACRemotes];
    ac= [tempArray objectAtIndex:0];
    if (btnindex==0 || btnindex==1)
    {
        [ac setValue:signalNames[btnindex] forKey:@"acstate"];
        [ACRemoteModelService updateRemote:ac];
        [(UIButton *)([self.view viewWithTag:AC]) setImage:[UIImage imageNamed:imagesname[btnindex]] forState:UIControlStateNormal];
    }
    else if (btnindex>=2 && btnindex<=6) {

        //Reset button which was previously set
        if (![[ac valueForKey:@"mode"] isEqualToString:@""]) {
                 NSInteger prev=[signalNames  indexOfObject:[ac valueForKey:@"mode"]];
                 [(UIButton *)([self.view viewWithTag:prev]) setImage:[UIImage imageNamed:signalNames[prev]] forState:UIControlStateNormal];
             }
        //set current pressed button
        [ac setValue:signalNames[btnindex] forKey:@"mode"];
             [ACRemoteModelService updateRemote:ac];
        [(UIButton *)([self.view viewWithTag:btnindex]) setImage:[UIImage imageNamed:imagesname[btnindex]] forState:UIControlStateNormal];
    }
    else if (btnindex==7 || btnindex==8)
    {
        [ac setValue:signalNames[btnindex] forKey:@"timer"];
        [ACRemoteModelService updateRemote:ac];
        [(UIButton *)([self.view viewWithTag:TIMER]) setImage:[UIImage imageNamed:imagesname[btnindex]] forState:UIControlStateNormal];
    }
    else if (btnindex== 9 || btnindex==10)
    {
        [ac setValue:signalNames[btnindex] forKey:@"turbo"];
        [ACRemoteModelService updateRemote:ac];
        [(UIButton *)([self.view viewWithTag:TURBO]) setImage:[UIImage imageNamed:imagesname[btnindex]] forState:UIControlStateNormal];
    }
    else if (btnindex == 12 || btnindex ==11)
    {
        [ac setValue:signalNames[btnindex] forKey:@"night"];
        [ACRemoteModelService updateRemote:ac];
        [(UIButton *)([self.view viewWithTag:NIGHT]) setImage:[UIImage imageNamed:imagesname[btnindex]] forState:UIControlStateNormal];
        
    }
       else if (btnindex>=15 && btnindex<=29)
    {
        [ac setValue:[NSString stringWithFormat:@"%f",point1.x] forKey:@"slider"];
        [ACRemoteModelService updateRemote:ac];

    }
}


#pragma mark - String Encoding for NSURLRequest

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
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]%",
                                                                                 kCFStringEncodingUTF8);
}

// This will open and close the side drawer

- (IBAction)openClose:(id)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
}



@end
