//
//  IRRoomSelectViewController.h
//  IRAutomation
//
//  Created by bharat jain on 3/9/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRRoomSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *imgList;
    NSArray *nameList;

}

- (void)initialize;

@end
